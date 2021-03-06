

library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(ggplot2)
library(DT)
library(dplyr)
library(readr)
library(htmltools)
library(leaflet)
library(rgdal)
library(raster)


###########loading dataset##########
wq<-read_csv("./www/wq_all.csv")
var1<-unique(wq$Round)
cystem<-unique(wq$System)
parameter<-unique(wq$Parameter)
ecoli<-read_csv("./www/ecoli.csv")
ph<-read_csv("./www/pH.csv")
turbidity<-read_csv("./www/turbidity.csv")
conductivity<-read_csv("./www/conductivity.csv")



###########loading shapefiles#######
labs<-read_csv("./www/labs_region.csv")
ghana<-readOGR("./www/Shapefile2.shp")
labshp<-readOGR("./www/labs.shp")
##############ui module##########
uimodule<-function(id){
  ns<-NS(id)
  sidebarLayout(
    sidebarPanel(width = 4,
                 h2(tags$b("Overview")),
                 h3(tags$p("This app displays water quality test results for systems enrolled in the Assurance Fund in Asutifi North, Ghana.")), 
                 h3(tags$p("The program was launched in March 2020 with 10 water systems. Water samples are tested once a month.")),
                 h3(tags$p("The first round of water samples tested (Round 1) was in March 2020, the second round (Round 2) was in April, 
                               third round (Round 3) in May, fourth round (Round 4) in June and fifth round (Round 5) in July.")),
                 h3(tags$p("The water samples tested were from three main water systems: Handpump, Mechanized borehole, Piped system.")),
                 h3(tags$p("The results tab displays the summary plots, and the data tab displays the raw data.")),
                 h3(tags$p("The map displays the regional water quality testing laboratories for each region and the dynamic area of coverage."))
    ),
    
    mainPanel(column(8,
                     fluidRow(
                       column(4,
                              selectInput(ns("round"),
                                          label = h4("Select results round"),
                                          choices = c("All",var1))
                       ),
                       column(4,
                              selectInput(ns("system"),
                                          label = h4("Select water system"),
                                          choices = c("All",cystem))
                       ),
                       
                       column(4,
                              selectInput(ns("peramater"),
                                          label = h4("Select parameter"),
                                          choices = c(parameter)
                                          )
                              )
                     ),
                     tabsetPanel(
                       tabPanel(h3("Results"),
                            br(),
                            fluidRow(
                             tabBox(
                                 title="",
                                 width=12,
                                 tabPanel(
                                 title = h4("Ecoli (CFU/100mL)"),
                                 tabBox(title = "",
                                        width = 12,
                                        tabPanel(title = h4("Count plots"),
                                                 h4(tags$p("The plot shows the E.coli contamination levels count by water system and results round.")),
                                                 plotOutput(ns("result"),
                                                            height = 500,width = "100%")),
                                        tabPanel(title = h4("Percentage plots"),
                                                 h4(tags$p("The plot shows the E.coli contamination levels percent by water system and results round.")),
                                                 plotOutput(ns("perc"),
                                                            height = 500,width = "100%")),
                                        tabPanel(title = h4("General plots"), 
                                                 h4(tags$p("The plot shows the average E.coli contamination levels by water system for all the rounds.")),
                                                 plotOutput(ns("gen"),
                                                            height = 400,width = "100%"))
                                 ) #end ecoli results

                                  ),
                                   tabPanel(
                                     title = h4("PH"),
                                     h4(tags$p("The plot shows the pH levels per water system for each of the rounds of results.")),
                                     br(),
                                     plotOutput(ns("ph"),width = "100%",height = 500)
                                   ),
                                   tabPanel(
                                     title = h4("Turbidity (NTU)"),
                                     h4(tags$p("The plot shows the Turbidity (NTU) levels per water system for each of the rounds of results.")),
                                     br(),
                                     plotOutput(ns("turb"),width = "100%",height = 500)
                                   ),
                                   tabPanel(
                                     title = h4("Conductivity (micromhos/cm)"),
                                     h4(tags$p("The plot shows the Conductivity (micromhos/cm) levels per water system for each of the rounds of results.")),
                                     br(),
                                     plotOutput(ns("cond"),width = "100%",height = 500)
                                   )
                             )
                               
                                  
                                ) #end fluidrow
                                
                                
                       ),
                       
                       tabPanel(h3("Data"),
                                br(),
                                
                                fluidRow(
                                  column(12,
                                         dataTableOutput(ns("data"))    
                                  )  
                                )
                       ),
                       
                       tabPanel(h3("Map"),
                                fluidRow(
                                  column(12,
                                         h4(tags$p("The map shows the coverage area for each regional lab in metres.")),
                                         numericInput(ns("dist"),label = h4("Input the radius coverage (Metres)"),value = 150000),
                                         leafletOutput(ns("map"),height = 500,width = "100%")  
                                         
                                  )
                                  
                                )
                                
                       )
                       
                     )
    )
    
    )
  )# end sidebar layout
}



###################server module#########################
servermodule<-function(id){
  moduleServer(id, function(input, output, session){
    
    #####all reactive function#######
    sys_react<-reactive({
      if(input$system!="All" ){
        wq %>% filter(System==input$system)
      }
      else{
        wq
      }
    }) #end
    
    wq_react<-reactive({
      if(input$round!="All"){
        sys_react() %>% filter(Round==input$round)
      }
      else{
        sys_react()
      }
    }) #end  
    
    ###############ph reactive function######
    sys_react2<-reactive({
      if(input$system!="All" ){
        ph %>% filter(System==input$system)
      }
      else{
        ph
      }
    }) #end
    
    
    ph_react<-reactive({
      if(input$round!="All"){
        sys_react2() %>% filter(Round==input$round)
      }
      else{
        sys_react2()
      }
    }) #end  
    
    ##############turbidity reactive function###########
    sys_react3<-reactive({
      if(input$system!="All" ){
        turbidity %>% filter(System==input$system)
      }
      else{
        turbidity
      }
    }) #end
    
    
    turb_react<-reactive({
      if(input$round!="All"){
        sys_react3() %>% filter(Round==input$round)
      }
      else{
        sys_react3()
      }
    }) #end  
    
    #####################conductivity##################
    sys_react4<-reactive({
      if(input$system!="All" ){
        conductivity %>% filter(System==input$system)
      }
      else{
        conductivity
      }
    }) #end
    
    
    cond_react<-reactive({
      if(input$round!="All"){
        sys_react4() %>% filter(Round==input$round)
      }
      else{
        sys_react4()
      }
    }) #end 
    
    ################table reactive function###########
    parameter_react<-reactive({
      wq_react() %>% filter(Parameter==input$peramater)
    })  
    
    
    ########reactive function for area coverage######
    bufer<-reactive({
      buffer(labshp,width=input$dist,dissolve=FALSE)
    })
    
    
#####################################ECOLI########################################    
    ###########count plot##########
    output$result<-renderPlot({
      wq_react() %>% filter(!is.na(Value) & Parameter=="Ecoli(CFU/100mL)") %>% count(Value,System,Round) %>%
        ggplot(aes(x=1,y=n,fill=Value))+
        geom_bar(stat = "identity")+
        scale_y_continuous(breaks = c(0,2,4,6,8,10))+
        scale_fill_manual(values=c("deepskyblue2","mediumseagreen","indianred1"),
                          breaks=c("Low","Intermediate","High"),
                          labels=c("Low (<1 CFU/100mL)","Intermediate (1-9 CFU/100mL)","High (10-100 CFU/100mL )")
        )+
        facet_wrap(~Round)+
        labs(
          y="Water system count (n=10)",
          fill="WHO Risk Level"

        )+
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_text(size=16),
          axis.text.y = element_text(size=14),
          strip.text = element_text(size = 10),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 12)
        )

    })#end
    
    ########################percentage plot############
    output$perc<-renderPlot({
      wq_react() %>% filter(!is.na(Value) & Parameter=="Ecoli(CFU/100mL)") %>% count(Value,System,Round) %>%
        #mutate(percentage=100*n/sum(n)) %>%
        ggplot(aes(x=1,y=10*n,fill=Value))+
        geom_bar(stat ="identity")+
        scale_y_continuous(breaks = c(0,20,40,60,80,100))+
        scale_fill_manual(values=c("deepskyblue2","mediumseagreen","indianred1"),
                          breaks=c("Low","Intermediate","High"),
                          labels=c("Low (<1 CFU/100mL)","Intermediate (1-9 CFU/100mL)","High (10-100 CFU/100mL )")
        )+
        labs(
          y="Percentage of water system (n=10)",
          fill="WHO Risk Level",
          caption = "Sample(n) = 10"
        )+
        #scale_y_continuous(labels = scales::percent_format())+
        facet_wrap(~Round)+
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_text(size=16),
          axis.text.y = element_text(size=14),
          strip.text = element_text(size = 10),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 12),
          plot.caption = element_text(size = 14)
        )

    })
   
  ######################general plot#######################  
    output$gen<-renderPlot({
      wq_react() %>% filter(!is.na(Value) & Parameter=="Ecoli(CFU/100mL)" ) %>% count(Value,System) %>%
        mutate(percentage=round(100*n/sum(n)),0) %>%
        ggplot(aes(x=1,y=percentage,fill=Value))+
        geom_bar(stat ="identity")+
        scale_y_continuous(breaks = c(0,20,40,60,80,100))+
        scale_fill_manual(values=c("deepskyblue2","mediumseagreen","indianred1"),
                          breaks=c("Low","Intermediate","High"),
                          labels=c("Low (<1 CFU/100mL)","Intermediate (1-9 CFU/100mL)","High (10-100 CFU/100mL )")
        )+
        coord_flip()+
        labs(
          y="Percentage of water system (n=10)",
          fill="WHO Risk Level",
          caption = "Sample(n) = 10"
        )+
        theme(
          axis.title.y = element_blank(),
          axis.title.x = element_text(size = 16),
          axis.text.x = element_text(size = 14),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 12),
          plot.caption = element_text(size = 14)
          # legend.direction ="horizontal",
          # legend.position = "bottom"
        )
    })#end
    
    
#############################################PH##################################
    output$ph<-renderPlot({
        ggplot(data = ph_react(),aes(x=reorder(Name,Value),y=Value,fill=System))+
        geom_col()+
        facet_wrap(~Round)+
        labs(
          y="pH level (n=10)",
          x="Water Kiosk",
          fill="Water system",
          caption = "Sample(n) = 10"
        )+
        theme(
          axis.title = element_text(size = 12),
          axis.text.y = element_text(size = 11),
          axis.text.x = element_text(angle = 45,size = 9),
          plot.caption = element_text(size = 12),
          legend.text = element_text(size =12 ),
          legend.title = element_text(size = 12)
        )
      
    })
    
    
#####################################Turbidity###################################
    output$turb<-renderPlot({
      ggplot(data = turb_react(),aes(x=reorder(Name,Value),y=Value,fill=System))+
        geom_col()+
        facet_wrap(~Round)+
        labs(
          y="Turbidity level (n=10)",
          x="Water Kiosk",
          fill="Water system",
          caption = "Sample(n) = 10"
        )+
        theme(
          axis.title = element_text(size = 12),
          axis.text.y = element_text(size = 11),
          axis.text.x = element_text(angle = 45,size = 9),
          plot.caption = element_text(size = 12),
          legend.text = element_text(size =12 ),
          legend.title = element_text(size = 12)
        )
    })
    
    
#####################################Conductivity################################
    output$cond<-renderPlot({
      ggplot(data = cond_react(),aes(x=reorder(Name,Value),y=Value,fill=System))+
        geom_col()+
        facet_wrap(~Round)+
        labs(
          y="Conductivity level (n=10)",
          x="Water Kiosk",
          fill="Water system",
          caption = "Sample(n) = 10"
        )+
        theme(
          axis.title = element_text(size = 12),
          axis.text.y = element_text(size = 11),
          axis.text.x = element_text(angle = 45,size = 9),
          plot.caption = element_text(size = 12),
          legend.text = element_text(size =12 ),
          legend.title = element_text(size = 12)
        )
    })
    
    ###############table output##########
    output$data<-renderDataTable({
      DT::datatable(parameter_react(), filter= "top")
    })
    
    
    ############map output###########
    output$map<-renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(
          data = ghana,
          fill = F,
          color = "blue",
          weight = 3
        )%>%
        addCircleMarkers(
          data=labs,
          fillColor = "red",
          fillOpacity = 1.0,
          radius = 8,
          stroke = FALSE,
          lat = ~lat,
          lng = ~lon,
          label = paste0(labs$`Treatment Plant`)
        ) %>%
        addPolylines(
          data = bufer(),
          color = "red",
          weight = 2.5
        )
      
    }
    
    ) #end of basemap
    
    
  })
}

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("WATER QUALITY TEST RESULTS"),
  uimodule("wqresults")
  
)# end fluidpage

# Define server logic required to draw a histogram
server <- function(input, output) {
  servermodule("wqresults")
  
}

# Run the application 
shinyApp(ui = ui, server = server)
