library(shiny)
library(openxlsx)

# Define UI
ui <- fluidPage(
  titlePanel("Data Entry App"),
  sidebarLayout(
    sidebarPanel(
      textInput("id", "Participant ID:"),
      textInput("name", "Name:"),
      radioButtons("gender", "Gender:", choices = c("Male", "Female", "Other"), inline = TRUE),
      numericInput("age", "Age:", value = NULL),
      numericInput("weight", "Weight:", value = NULL),
      numericInput("height", "Height:", value = NULL),
      selectInput("treat", "Treatment Assigned :", c("Intervention", "Placebo")),
      sliderInput("sqt", "Sleep Quality Time(SQT):", min = 1, max = 10, value = 1),
      sliderInput("sd", "Sleep Duration(SD):", min = 0, max = 10, value = 0),
      sliderInput("ds", "Daytime sleep(DS):", min = 0, max = 10, value = 0),
      actionButton("saveBtn", "Save")
    ),
    
    mainPanel(
      tableOutput("dataTable"),
      
      tags$script(HTML('
    $(document).ready(function() {
      $("input[name=\'gender\']").prop("checked", false);
    });
    ')) 
      
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Check if the data file exists, if not, create a new dataframe
  if (file.exists("biostat_data.xlsx")) {
    # Load the existing data from the file
    data <- read.xlsx("biostat_data.xlsx")
  } else {
    # Create a new empty dataframe
    data <- data.frame(ID = numeric(), Name = character(), Gender = character(), Age = numeric(),
                       Weight = numeric(), Height = numeric(), Treatment = character(),
                       SQT = numeric(), SD = numeric(), DS = numeric(), stringsAsFactors = FALSE)
  }
  
  # Event handler for the Save button
  observeEvent(input$saveBtn, {
    # Create a new row with the input values
    newRow <- data.frame(ID = input$id, Name = input$name, Gender = input$gender, Age = input$age,
                         Weight = input$weight, Height = input$height, Treatment = input$treat,
                         SQT = input$sqt, SD = input$sd, DS = input$ds, stringsAsFactors = FALSE)
    
    # Append the new row to the existing data
    updatedData <- rbind(data, newRow)
    
    # Update the data variable
    data <<- updatedData
    
    # Save the data to the file
    write.xlsx(updatedData, "biostat_data.xlsx", rowNames = FALSE)
    
    # Provide a confirmation message
    showModal(modalDialog("Data saved successfully!", easyClose = TRUE))
  })
  
  # Render the data table
  output$dataTable <- renderTable({
    data
  })
}

# Create the Shiny app
shinyApp(ui, server)
