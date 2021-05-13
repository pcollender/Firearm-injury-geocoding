library(shiny)
library(DT)

css <- "
.nowrap {
white-space: nowrap;
}"


ui <- fluidPage(
  tags$head(
    tags$style(HTML(css))
  ),
  # App title ----
  titlePanel("Select data for geocoding"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      fileInput(inputId = "file",label = NULL,accept = '\\.csv$')
      
      ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      htmlOutput("caption"),
      DT::dataTableOutput("view"),
      textOutput("selectCaption"),
      uiOutput('conditionalPanel')
    )
  )
)

server <- function(input, output) {
  
  datasetInput <- reactive({
    req(input$file$datapath)
    
    read.csv(input$file$datapath, stringsAsFactors = F)
    
  })
  
  
  output$caption = renderUI({req(input$file$datapath)
                              HTML('Select column containing address data <br/>
                              <b/>(REMINDER: column should be formatted as "<i/>{street address} {city} {state} {5 digit zip}</i/>")</b/> <br/>
                              (e.g. <i/>"1234 Main st Fairfield MA 12345"</i/>)')})
  
  output$view <- DT::renderDataTable(datasetInput(),
                                     selection = list(target = "column",mode='single'),
                                     options = list(searching = FALSE, 
                                                    columnDefs = list(
                                                      list(className = "nowrap", targets = "_all")
                                                    )))
  
  output$selectCaption = renderText({
    req(input$view_columns_selected)
    paste('Selected column',colnames(datasetInput())[input$view_columns_selected])
  })
  
  output$conditionalPanel = renderUI({
    req(input$view_columns_selected)
    actionButton("confirmSelection","Confirm selection and proceed")
  })
  
  observeEvent(input$confirmSelection,
               {
                 dat = datasetInput()
                 write.csv(dat[,input$view_columns_selected], file = 'temp.csv', row.names = F)
                 stopApp()
               }
               )
  
}

shinyApp(ui, server)
