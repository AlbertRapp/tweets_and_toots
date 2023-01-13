setwd(here::here())
library(shiny)
library(bs4Dash)
library(shinyjs)



platform_boxUI <- function(id) {
  ns <- NS(id)
  tagList(
    box(
      textAreaInput(ns('message'), label = NULL),
      textOutput(ns('n_char')),
      fileInput(ns('img_upload'), label = ''),
      uiOutput(ns('img_output')),
      collapsible = FALSE,
      headerBorder = FALSE,
      closable = TRUE
    )
  )
}

platform_boxServer <- function(id, char_limit) {
  moduleServer(
    id,
    function(input, output, session) {
      output$n_char <- renderText({
        char_limit - stringr::str_length(input$message)
      })
      
      output$img_output <- renderUI({
        req(input$img_upload)
        print(input$img_upload$datapath)
        tags$div(
          tags$image(
            src = base64enc::dataURI(file = input$img_upload$datapath, mime = "image/png"),
            style = "max-width:100%; max-height:100%;"
          ),
          style = "width:100%; height:100px;"
        )
      })
    }
  )
}

textcardUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      fluidRow(
        platform_boxUI(ns('twitter')),
        platform_boxUI(ns('mastodon'))
      ),
      id = ns('div')
    )
  )
}

textcardServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      platform_boxServer('twitter', char_limit = 280)
      platform_boxServer('mastodon', char_limit = 500)
    }
  )
}

ui <- dashboardPage(
  header = dashboardHeader(),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem(text = 'Writer', tabName = 'writer_tab', icon = icon('keyboard')),
      menuItem(text = 'Scheduled', tabName = 'scheduled_tab', icon = icon('calendar')),
      menuItem(text = 'Published', tabName = 'publish_tab', icon = icon('upload')),
      menuItem(text = 'Analytics', tabName = 'analytics_tab', icon = icon('chart-line'))
    )
  ),
  body = dashboardBody(
    
    tags$script(readLines('www/resize_textareas.js') |> HTML()),
    tags$script(readLines('www/get_messages.js') |> HTML()),
    tabItems(
      tabItem(
        'writer_tab',
        sortable(
          textcardUI('textcard1'),
          actionButton('add_btn', label = 'Add Msg'),
          actionButton('collect_messages', label = 'Collect', onclick = 'getMessages("bla");')
        )
      )
    )
  )
 
)

server <- function(input, output, session) {
  textcardServer('textcard1')
  
  observe({
    mod_nmbr <- input$add_btn + 1
    mod_id <- paste0('textcard', mod_nmbr)
    insertUI(
      '#add_btn',
      where = "beforeBegin",
      ui = textcardUI(mod_id)
    )
    textcardServer(mod_id)
    
  }) |> bindEvent(input$add_btn)
  
  msgs_twitter_reactive <- reactive({input$msgs_twitter})
  msgs_mastodon_reactive <- reactive({input$msgs_mastodon})
  
  # observe({
  #   js$getMessages()
  # }) |> bindEvent(input$collect_messages)
 
  observe({
    req(msgs_twitter_reactive())
    print(msgs_twitter_reactive())
  }) |> bindEvent(msgs_twitter_reactive(), input$collect_messages)
  observe({
    req(msgs_mastodon_reactive())
    print(msgs_mastodon_reactive())
  }) |> bindEvent(msgs_mastodon_reactive(), input$collect_messages)
}

shinyApp(ui, server)