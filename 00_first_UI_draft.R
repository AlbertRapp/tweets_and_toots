setwd(here::here())
library(shiny)
library(bs4Dash)
library(shinyjs)

generate_resize_js_code <- function(element_id) {
  glue::glue("document.addEventListener('DOMNodeInserted', function(event) {
    var observe;
    if (window.attachEvent) {
      observe = function (element, event, handler) {
        element.attachEvent('on'+event, handler);
      };
    }
    else {
      observe = function (element, event, handler) {
        element.addEventListener(event, handler, false);
      };
    }
    function init () {
      var text = document.getElementById('<<element_id>>');
      function resize () {
        text.style.height = 'auto';
        text.style.height = text.scrollHeight+'px';
      }
      /* 0-timeout to get the already changed text */
        function delayedResize () {
          window.setTimeout(resize, 0);
        }
      observe(text, 'change',  resize);
      observe(text, 'cut',     delayedResize);
      observe(text, 'paste',   delayedResize);
      observe(text, 'drop',    delayedResize);
      observe(text, 'keydown', delayedResize);

      resize();
    };init()
  })
  ", .open = "<<", .close = ">>")
}

platform_boxUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$script(generate_resize_js_code(ns('message'))),
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
    
    useShinyjs(),
    extendShinyjs(
      script = 'get_messages.js',
      functions = c('getMessages')
    ),
    tabItems(
      tabItem(
        'writer_tab',
        sortable(
          textcardUI('textcard1'),
          actionButton('add_btn', label = 'Add Msg'),
          actionButton('collect_messages', label = 'Collect')
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
  
  observe({
    js$getMessages()
  }) |> bindEvent(input$collect_messages)
 
  observe({
    print(msgs_twitter_reactive())
  }) |> bindEvent(msgs_twitter_reactive())
  observe({
    print(msgs_mastodon_reactive())
  }) |> bindEvent(msgs_mastodon_reactive())
}

shinyApp(ui, server)