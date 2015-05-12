


reactiveNetwork <- function (outputId)
{
    HTML(paste("<div id=\"", outputId, "\" class=\"shiny-network-output\"><svg /></div>", sep=""))
}

row <- function(...)
{
    tags$div(class="row", ...)
}

col <- function(width, ...)
{
    tags$div(class=paste0("span", width), ...)
}


busy_dialog <- function(start.string, end.string)
{
    conditionalPanel(
        condition <- "$('html').hasClass('shiny-busy')",
        br(),
        p(strong("Processing data...please wait."))
    )
}


render_graph_ui <- function(...){renderUI({
fluidPage(
    fluidRow(
        column(9,
            tags$head(tags$script(src = "http://d3js.org/d3.v2.js")),
            tags$head(tags$script(src = "graph.js")),
            tags$head(tags$script(src = "d3.min.js")),
            singleton(tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'graph.css'))),
            reactiveNetwork(outputId = "graphui_mainnet")
        ),
        column(3,
    
            selectizeInput("graphui_selected_graph", "Choose a map:", choices = c(""), width = "100%", options = list(onChange = I("function() {var sel = d3.select('g'); if(!sel.empty()) Shiny.onInputChange('graphui_cur_transform', sel.attr('transform'))}"))),
            selectInput("graphui_marker", "Color nodes by marker expression:", choices = c(""), width = "100%"),
            selectInput("graphui_color_scaling", "Color scaling:", choices = c("global", "local"), width = "100%"),
            selectInput("graphui_markers_to_plot", "Markers to plot in cluster view:", choices = c(""), width = "100%", multiple = T),
            actionButton("graphui_reset_colors", "Reset colors"), br(),
            actionButton("graphui_reset_graph_position", "Reset graph position"), br(),
            actionButton("graphui_toggle_landmark_labels", "Toggle landmark labels"), br(),
            actionButton("graphui_toggle_cluster_labels", "Toggle cluster labels"), br(),
            actionButton("graphui_toggle_node_size", "Toggle node size"), br(),
            br(), br(),
            verbatimTextOutput("graphui_dialog1"),
            htmlOutput("graphui_dialog2"),br(),
            htmlOutput("graphui_dialog3"),
            br(),br(),
            p("Technical Note: As previously described elsewhere, we have observed higher background staining on Neutrophils, especially for antibodies used at higher concentrations (see Table S1). Therefore, protein expression on this population should be interpreted with caution")
        )
    ),
    
    

    fluidRow(
        column(12,
            verbatimTextOutput("graphui_plot_title")
        )
    ),
    
    fluidRow(
        column(12,
            plotOutput("graphui_plot")
        )
    )
)
})}



shinyServer(function(input, output, session)
{
    output$graphUI <- render_graph_ui(input, output, session)
    file_name <- file.choose()

    
    #GraphUI functions

    scaffold_data <- reactive({
        if(file_name != "")
        {
            print("Loading data...")
            data <- MouseImmuneReference:::my_load(file_name)
            updateSelectInput(session, "graphui_selected_graph", choices = c("", names(data$graphs)))
            return(data)
        }
        else
            return(NULL)
    })
    
    output$graphui_mainnet <- reactive({
        sc.data <- scaffold_data()
        if(!is.null(sc.data))
        {
            if(!is.null(input$graphui_selected_graph) && input$graphui_selected_graph != "")
            {
                attrs <- MouseImmuneReference:::get_numeric_vertex_attributes(sc.data, input$graphui_selected_graph)
                updateSelectInput(session, "graphui_marker", choices = c("", attrs))
                updateSelectInput(session, "graphui_markers_to_plot", choices = attrs)
                MouseImmuneReference:::get_graph(sc.data, input$graphui_selected_graph, input$graphui_cur_transform)
            }
        }
        else
            return(NULL)
    })
    
    output$graphui_dialog1 <- reactive({
        sc.data <- scaffold_data()
        ret <- ""
        if(!is.null(sc.data))
            ret <- sprintf("Markers used for SCAFFoLD: %s", paste(sc.data$scaffold.col.names, collapse = ", "))
        return(ret)
    })
    
    output$graphui_dialog2 <- renderUI({
        if(!is.null(input$graphui_selected_landmark) && input$graphui_selected_landmark != "")
        {
            sc.data <- scaffold_data()
            if(!is.null(sc.data))
                return(MouseImmuneReference:::get_pubmed_references(sc.data, input$graphui_selected_graph, input$graphui_selected_landmark))
        }
    })
    
    output$graphui_dialog3 <- renderUI({
        if(!is.null(input$graphui_selected_graph) && input$graphui_selected_graph == "BM-C57BL_6_Fluorescence.clustered.txt")
        {
            return(HTML("8-color fluorescence experiment from Bone Marrow of C57BL/6 mice<br>Data from Qiu et al., Nat Biotechnol (2011) 'Extracting a cellular hierarchy from high-dimensional cytometry data with SPADE', PMID: <a href='http://www.ncbi.nlm.nih.gov/pubmed/21964415' target='_blank'>21964415</a>"))
        }
    })



    output$graphui_plot = renderPlot({
        p <- NULL
        if(!is.null(input$graphui_selected_cluster) && input$graphui_selected_cluster != "")
        {
            col.names <- input$graphui_markers_to_plot
            print(input$graphui_selected_cluster)
            if(length(col.names >= 1))
                p <- MouseImmuneReference:::plot_cluster(scaffold_data(), input$graphui_selected_cluster, input$graphui_selected_graph, input$graphui_markers_to_plot)
        }
        print(p)
    })


    output$graphui_plot_title = renderPrint({
        if(!is.null(input$graphui_selected_cluster) && input$graphui_selected_cluster != "")
            sprintf("Plotting cluster %s", input$graphui_selected_cluster)
    })
    
    observe({
        if(is.null(input$graphui_marker)) return(NULL)
        sel.marker <- input$graphui_marker
        if(sel.marker != "")
        {
            sc.data <- scaffold_data()
            if(!is.null(sc.data))
            {
                v <- MouseImmuneReference:::get_color_for_marker(sc.data, sel.marker, input$graphui_selected_graph, input$graphui_color_scaling)
                session$sendCustomMessage(type = "color_nodes", v)
            }
        }
    })
    
    observe({
        if(!is.null(input$graphui_reset_colors) && input$graphui_reset_colors != 0)
        {
            session$sendCustomMessage(type = "reset_colors", "none")
        }
    })
    
    observe({
        if(!is.null(input$graphui_reset_graph_position) && input$graphui_reset_graph_position != 0)
        {
            session$sendCustomMessage(type = "reset_graph_position", "none")
        }
    })
    
    observe({
        if(!is.null(input$graphui_toggle_landmark_labels) && input$graphui_toggle_landmark_labels != 0)
        {
            display <- ifelse(input$graphui_toggle_landmark_labels %% 2 == 0, "", "none")
            session$sendCustomMessage(type = "toggle_label", list(target = "landmark", display = display))
        }
    })
    
    observe({
        if(!is.null(input$graphui_toggle_cluster_labels) && input$graphui_toggle_cluster_labels != 0)
        {
            display <- ifelse(input$graphui_toggle_cluster_labels %% 2 == 0, "none", "")
            session$sendCustomMessage(type = "toggle_label", list(target = "cluster", display = display))
        }
    })
    
    observe({
        if(!is.null(input$graphui_toggle_node_size) && input$graphui_toggle_node_size != 0)
        {
            display <- ifelse(input$graphui_toggle_node_size %% 2 == 0, "proportional", "default")
            session$sendCustomMessage(type = "toggle_node_size", list(display = display))
        }
    })

})



