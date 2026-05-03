#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Load Libraries
library(shiny)
library(tidyverse)
library(haven)
library(gtsummary)
library (htmltools)
library(knitr)
library(readr)
library(dplyr)
library(sparklyr)
library(here)
library(texreg)
library(plotly)
library(stargazer)
library(DT)
library(ggplot2)
library(rsconnect)
library(rmarkdown)
library(broom)
library(knitr)



# Load data
ZA7500_subset <- read.csv("data/ZA7500_subset.csv")

ui <- fluidPage(
        sidebarLayout(
                sidebarPanel(
                        selectInput("controller", "Navigation",
                                    choices = c("Main", "Exploration", "Regression")),
                        selectInput("country", "Exploration Country:",
                                    choices = c("Overall", unique(ZA7500_subset$c_abrv))),
                        selectInput("outcome", "Select Outcome:", choices = c("Jobs to Nationals", "Mothers Working"), selected = "Jobs to Nationals"),
                        selectInput("control", "Additional Model Predictor:", choices = c("Sex", "Education"), selected = "Sex"),
                        sliderInput("age_poly", "Model Polynomial Degree for Age:",
                                    min = 1, max = 5, value = 1, step = 1),
                        actionButton("submit", "Submit"),
                        p(" "),
                        downloadButton("download_report", "Download Full Report (HTML)")
                ),
                mainPanel(
                        tabsetPanel(
                                id = "switcher",
                                tabPanel("Main",
                                         h1("Main"),
                                         p("This is the home tab of this app. The goal of this app is to allow users to analyze 2017 EVS Data, specially focused on beliefs in the EU on the impact on mothers working on their children and hiring preferences by employers when jobs are scarce (citizens vs immigrants)."),
                                         p("Ther are 2 data viewing tabs (Exploration and Regression). First, explore the data on the exploration tab. Here, you can update the country (Overall or 1 country at a time) and the outcome (if a child suffers if the mother works and if jobs should be given to nationals) to see how the data changes. Then, head to the regression tab to explore how different inputs affect the coefficients, p-values, etc. for these outcomes."),
                                         p("Inputs: There are 4 inputs that will impact the outputs on the exploration and regression tabs. Hit submit at any time to update the outputs based on your selections."),
                                         p("Country: This will filter all outputs to the country of your choice"),
                                         p("Outcome: There are two outcomes. 1: If the child suffers when the mother works and if a job should be given to a national in times of economic trouble"),
                                         p("Controls: You can choose between sex and education"),
                                         p("Age polynomial: numeric input between 1 and 5. The default is 1."),
                                         p("Once you have a configuration you would like to save, you can export an html report.")
                                 ),
                                tabPanel("Exploration",
                                         h1("Exploration"),
                                         h2("Analysis of Outcome and Controls"),
                                         p("On this tab, there is analysis of the two outcomes (if a child suffers if the mother works and if jobs should be given to nationals) and the controls (age, education, and sex). This analysis will be done via graphs. Graphs will update based on the selections made."),
                                         h3("Outcome Plot"),
                                         dataTableOutput("plot_table"),
                                         plotlyOutput("selected_plot"),
                                         p(" "),
                                         p(" "),
                                         h3("Control 1: Age"),
                                         plotlyOutput("age_plot"),
                                         p(" "),
                                         p(" "),
                                         h3("Control 2: Sex"),
                                         plotlyOutput("sex_plot"),
                                         p(" "),
                                         p(" "),
                                         h3("Control 3: Education"),
                                         plotlyOutput("education_plot")
                                ),
                                tabPanel("Regression",
                                         h1("Regression Analysis"),
                                         p("On this tab, you can explore how different controls (sex and education) and age polynomials impact the regression coefficients for the outcome of your choice. Hit submit at any time to change the outcome and inputs. Data is not by filtered by country in this tab, but you can select the country in the exploration tab to see how the data looks for that country."),
                                         p(" "),
                                         h3("Model Performance Table"),
                                         tableOutput("model_table"),
                                         p(" "),
                                         p(" "),
                                         h3("Residual Plot"),
                                         plotlyOutput("residual_plot")
                                ) 
                        ))))


server <- function(input, output, session) {
        # Debug: Check if report.Rmd exists
        if (!file.exists("report.Rmd")) {
                stop("report.Rmd is missing! Current directory: ", getwd())
        }
        
        # Handle the "Show" dropdown to switch tabs
        observeEvent(input$controller, {
                updateTabsetPanel(session, "switcher", selected = input$controller)
        })
        
        
        # Reactive for filtering and processing data (triggered by submit button)
        plot_data <- eventReactive(input$submit, {
                req(input$country, input$outcome) 
                
                
                # Filter data by country including an overall option for all countries
                filtered_data <- if (input$country == "Overall") {
                        ZA7500_subset
                } else {
                        ZA7500_subset %>% filter(c_abrv == input$country)
                }
                
                # Process data based on plot type 
                if (input$outcome == "Jobs to Nationals") {
                        print("Processing Jobs to Nationals")
                        filtered_data %>%
                                group_by(age_decade) %>%
                                summarise(
                                        Agree_Strongly = sum(scare_factor == "Agree Strongly", na.rm = TRUE),
                                        Agree = sum(scare_factor == "Agree", na.rm = TRUE),
                                        Neither = sum(scare_factor == "Neither Agree nor Disagree", na.rm = TRUE),
                                        Disagree = sum(scare_factor == "Disagree", na.rm = TRUE),
                                        Disagree_Strongly = sum(scare_factor == "Disagree Strongly", na.rm = TRUE)
                                ) %>%
                                pivot_longer(cols = -age_decade, names_to = "variable", values_to = "values")
                        
                } else if (input$outcome == "Mothers Working") {
                        print("Processing Mothers Working")
                        filtered_data %>%
                                group_by(age_decade) %>%
                                summarise(
                                        Agree_Strongly = sum(suffer_factor == "Agree Strongly", na.rm = TRUE),
                                        Agree = sum(suffer_factor == "Agree", na.rm = TRUE),
                                        Disagree = sum(suffer_factor == "Disagree", na.rm = TRUE),
                                        Disagree_Strongly = sum(suffer_factor == "Disagree Strongly", na.rm = TRUE)
                                ) %>%
                                pivot_longer(cols = -age_decade, names_to = "variable", values_to = "values")
                }
        })
        
        # Render the selected plot
        output$selected_plot <- renderPlotly({
                req(input$outcome, plot_data())  # Ensure inputs and data exist
                
                p <- ggplot(plot_data(), aes(x = age_decade, y = values, fill = variable)) +
                        geom_bar(stat = "identity", position = "fill") +
                        labs(x = "Age Decade", y = "Percent of Responses", fill = "Level of Agreement") +
                        ggtitle(input$outcome) +
                        theme(      panel.grid.major = element_blank(),
                                    panel.grid.minor = element_blank(),
                                    panel.background = element_blank(),
                                    axis.line = element_line(color = "grey"),
                                    text = element_text(color = "grey"),
                                    axis.text.x = element_text(angle = 45, hjust = 1),
                                    plot.title = element_text(hjust = 0.5)) +
                        scale_fill_discrete(
                                labels = if (input$outcome == "Jobs to Nationals") {
                                        c("Agree Strongly", "Agree", "Neither Agree nor Disagree", "Disagree", "Disagree Strongly")
                                } else {
                                        c("Agree Strongly", "Agree", "Disagree", "Disagree Strongly")
                                }
                        )
        })
        # reactive for age graph including overall option for all countries
        x3 <- eventReactive(input$submit, { 
                filtered_data <- if (input$country == "Overall") {
                        ZA7500_subset
                } else {
                        ZA7500_subset %>% filter(c_abrv == input$country)
                }
                
                filtered_data %>%
                        group_by(age_decade) %>%
                        summarise(count = n())
        })
        
        # plot for age
        output$age_plot <- renderPlotly({
                age_plot <- ggplot(x3(), aes(x = age_decade, y = count)) +
                        geom_bar(stat = "identity") +
                        labs(x = "Age Decade", y = "Count") +
                        ggtitle("Count of Respondent Age by Decade") +
                        theme(
                                panel.grid.major = element_blank(), 
                                panel.grid.minor = element_blank(),
                                panel.background = element_blank(), 
                                axis.line = element_line(color = "grey"),   
                                text=element_text(color="grey"),
                                plot.title = element_text(hjust = 0.5))
        })
        
        # reactive for sex graph including overall option for all countries
        x4 <- eventReactive(input$submit, { 
                filtered_data <- if (input$country == "Overall") {
                        ZA7500_subset
                } else {
                        ZA7500_subset %>% filter(c_abrv == input$country)
                }
                
                filtered_data %>%
                        group_by(gender_factor) %>%
                        summarise(count = n())
        })             
        
        # plot for sex
        output$sex_plot <- renderPlotly({
                sex_plot <- ggplot(x4(), aes(x = gender_factor, y = count)) +
                        geom_bar(stat = "identity") +
                        labs(x = "Gender", y = "Count") +
                        ggtitle("Count of Respondent Gender") +
                        theme(
                                panel.grid.major = element_blank(), 
                                panel.grid.minor = element_blank(),
                                panel.background = element_blank(), 
                                axis.line = element_line(color = "grey"),   
                                text=element_text(color="grey"),
                                axis.text.x = element_text(angle = 45, hjust = 1),
                                plot.title = element_text(hjust = 0.5))
        })
        
        # reactive for education graph including overall option for all countries
        x5 <- eventReactive(input$submit, { 
                filtered_data <- if (input$country == "Overall") {
                        ZA7500_subset
                } else {
                        ZA7500_subset %>% filter(c_abrv == input$country)
                }
                
                filtered_data %>%
                        group_by(education_factor) %>%
                        summarise(count = n())
        })
        
        # plot for education
        output$education_plot <- renderPlotly({
                education_plot <- ggplot(x5(), aes(x = education_factor, y = count)) +
                        geom_bar(stat = "identity") +
                        labs(x = "Level of Education", y = "Count") +
                        ggtitle("Count of Respondent Level of Education") +
                        theme(
                                panel.grid.major = element_blank(), 
                                panel.grid.minor = element_blank(),
                                panel.background = element_blank(), 
                                axis.line = element_line(color = "grey"),   
                                text=element_text(color="grey"),
                                axis.text.x = element_text(angle = 45, hjust = 1),
                                plot.title = element_text(hjust = 0.5))
        })
        
        regression_model <- eventReactive(input$submit, {
                req(input$outcome, input$control, input$age_poly)
                
                # Select outcome column name (numeric)
                outcome_col <- if (input$outcome == "Jobs to Nationals") {
                        "v80"
                } else {
                        "v72"
                }
                
                # Select control column name
                control_col <- if (input$control == "Sex") {
                        "v225"
                } else {
                        "v243_edulvlb"
                }
                
                # Drop rows with NA in age, outcome, or control
                model_data <- drop_na(ZA7500_subset, age, !!sym(outcome_col), !!sym(control_col))
                
                # Construct formula (skip poly() for degree 1)
                if (input$age_poly == 1) {
                        formula <- as.formula(paste(outcome_col, "~ age +", control_col, sep = ""))
                } else {
                        formula <- as.formula(
                                paste(outcome_col, "~ age + poly(age, degree = ", input$age_poly, ") + ", control_col, sep = "")
                        )
                }
                
                # Fit linear regression
                model <- tryCatch({
                        lm(formula, data = model_data)
                }, error = function(e) {
                        print(paste("Model error:", e$message))
                        NULL
                })
                
                return(model)
        })
        
        # Output the model table
        output$model_table <- renderTable({
                model <- regression_model()
                req(model)
                broom::tidy(model, conf.int = TRUE)
        }, align = 'l', striped = TRUE, bordered = TRUE)
        
  
        # create a scatter plot that shows predicted versus residuals from the regression model
        output$residual_plot <- renderPlotly({
                model <- regression_model()
                req(model)
                model_data <- model$model
                model_data$residuals <- resid(model)
                model_data$fitted <- fitted(model)
                
                p <- ggplot(model_data, aes(x = fitted, y = residuals)) +
                        geom_point() +
                        geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
                        labs(x = "Fitted Values", y = "Residuals") +
                        ggtitle("Residuals vs Fitted Values") +
                        theme(
                                panel.grid.major = element_blank(), 
                                panel.grid.minor = element_blank(),
                                panel.background = element_blank(), 
                                axis.line = element_line(color = "grey"),   
                                text=element_text(color="grey"),
                                plot.title = element_text(hjust = 0.5))
        })
        
        # output an html report
        output$download_report <- downloadHandler(
                filename = function() {
                        paste("Regression_Report_", Sys.Date(), ".html", sep = "")
                },
                content = function(file) {
                        if (!file.exists("report.Rmd")) {
                                stop("report.Rmd not found in: ", getwd())
                        }
                        
                        # Render the report
                        rmarkdown::render(
                                "report.Rmd",
                                output_file = file,
                                params = list(
                                        outcome = input$outcome,
                                        control = input$control,
                                        age_poly = input$age_poly,
                                        country = input$country,
                                        plot_data = plot_data(),  
                                        x3 = x3(),
                                        x4 = x4(),
                                        x5 = x5(),
                                        regression_model = regression_model()),
                                envir = new.env(parent = globalenv())
                        )
                }
        )
}

shinyApp(ui, server)