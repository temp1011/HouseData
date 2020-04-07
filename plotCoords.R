library(shiny)
library(leaflet)
library(leafgl)
library(sf)
library(RPostgreSQL)

pg <- dbDriver("PostgreSQL")
con <- dbConnect(pg, user="docker", password="docker", host="localhost", port=5432)


ui <- fluidPage(leafletOutput("map"),
p(),
textOutput("bounds"))

onScreenPoints <- function(n, s, e, w) {
	#TODO maybe we can add some kind of index on coords2 to speed this up?
	sql <- sqlInterpolate(con, "SELECT id, coord[0], coord[1] FROM coords2 WHERE coord <@ box(point(?east, ?south), point(?west, ?north));",
	south=s, east=e, north=n, west=w)
	filteredPoints <- dbGetQuery(con, sql)
	if(!(length(filteredPoints) > 0)) {
		return(NULL)
	}
	print(summary(filteredPoints))
	colnames(filteredPoints) <- c("id", "longitude", "latitude")
	list(st_as_sf(filteredPoints[, 2:3], coords = c("longitude", "latitude")), filteredPoints[, 1])
}

server <- function(input, output, session) {
	output$map <- renderLeaflet({
		leaflet() %>%
		addTiles() %>%
		setView(-0.46142578125, 52.93384196273695, 6)
	})

	bds <- eventReactive(input$map_bounds, {
		paste(input$map_bounds, collapse=" ")
	})

	output$bounds <- renderText({ bds() })

	
	obs <- observe({
		print("zoom level")
		print(input$map_zoom)
		if(length(input$map_zoom) > 0 && input$map_zoom <= 9) {
			leafletProxy("map") %>%
				removeGlPoints(layerId = "markers")
			return(c())
		}

		if(!(length(input$map_bounds) > 0)) {
			return (c())
		}
		north <- input$map_bounds$north
		south <- input$map_bounds$south
		east <- input$map_bounds$east
		west <- input$map_bounds$west
		points_data = onScreenPoints(north, south, east, west)
		
		if(!length(points_data) > 0) {
			return (c())
		}
		leafletProxy("map") %>%
			removeGlPoints(layerId = "markers") %>%
			addGlPoints(data = points_data[[1]], layerId = "markers", popup = points_data[[2]])
		# Note: at the moment I'm pretty sure this leaks memory.
	})
}

options(shiny.port = 8870)
options(shiny.host = "192.168.0.17")

shinyApp(ui, server)
