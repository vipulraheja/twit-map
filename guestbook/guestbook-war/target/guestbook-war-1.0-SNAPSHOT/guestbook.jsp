<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.PreparedQuery" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>

<%@ page import="com.google.appengine.api.datastore.Query.Filter" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterPredicate" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator" %>
<%@ page import="com.google.appengine.api.datastore.Query.CompositeFilter" %>
<%@ page import="com.google.appengine.api.datastore.Query.CompositeFilterOperator" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.TreeSet" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
	<head>
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>

	    <meta charset="utf-8">
    	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">

    	<link href="http://cdn.jsdelivr.net/foundation/5.2.2/css/foundation.min.css" rel="stylesheet">

    	<!-- Custom styles for this template -->
    	<link href="/stylesheets/starter-template.css" rel="stylesheet">


		<link rel="shortcut icon" href="/images/favicon.ico">
		<link rel="apple-touch-icon" href="/images/apple-touch-icon.png">
		<link rel="apple-touch-icon" sizes="72x72" href="/images/apple-touch-icon-72x72.png">
		<link rel="apple-touch-icon" sizes="114x114" href="/images/apple-touch-icon-114x114.png">

	    <title>Heatmaps</title>
	    <style>
	      #map-canvas {
	        height: 100%;
	        width: 100%
	        margin-top: 	0px;
	        padding: 0px;
	      }
	      #panel {
	        position: absolute;
	        bottom: 0px;
	        width: 100%;
	        z-index: 5;
	        padding: 5px;
	      }
	      #button {
	      	margin: 0 !important;
	      }
	    </style>
	    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=visualization"></script>
	    
<!-- 	    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/> -->

	    <script>
	    
	    // Adding 500 Data Points
		var map, pointarray, heatmap;

		var tweetData = [];

		function initialize() {
			var mapOptions = {
			    zoom: 3,
			    center: new google.maps.LatLng(0,0),
			    mapTypeId: google.maps.MapTypeId.TERRAIN,
			    styles: [
					{
					"featureType": "landscape",
					"stylers": [
					  { "invert_lightness": true },
					  { "lightness": 5 },
					  { "color": "#0d3747" }
					]
					},{
					"featureType": "administrative.country",
					"stylers": [
					  { "weight": 0.9 },
					  { "color": "#d4e867" }
					]
					},{
					"featureType": "landscape.natural.terrain",
					"elementType": "labels.text"  }
					]
			  //   styles: [
 				// {
    	// 			"featureType": "landscape.natural.landcover",
    	// 			"stylers": [
     //  					{ "color": "#ff0895" },
     //  					{ "hue": "#0011ff" },
     //  					{ "weight": 1.4 },
     //  					{ "saturation": -26 }]
  			// 	},{}]
			};

			map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

			var pointArray = new google.maps.MVCArray(tweetData);

			heatmap = new google.maps.visualization.HeatmapLayer({
				data: pointArray
			});

			heatmap.setMap(map);
		}

		function selectKeyword(){
 			$.ajax({
        	url: "location", //sumbits it to the given url of the form
        	data: {'keyword': document.getElementById("keys").value},
        	dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    		}).success(function(json){
		        //act on result.
		        tweetData.length=0;
		        console.log(tweetData);

		        var jsonString = JSON.stringify(json);
		        var jsonParsed = JSON.parse(jsonString);
		        var latitude= jsonParsed.latitude;
		        var longitude= jsonParsed.longitude;

		        console.log(longitude.length);

		        for(var i=0; i<longitude.length; i++){
		          tweetData.push(new google.maps.LatLng(latitude[i], longitude[i]));
		        }

		        console.log(tweetData);
		        initialize();
		    	});
		  		// window.alert(document.getElementById("keys").value);
		}

		function toggleHeatmap() {
			heatmap.setMap(heatmap.getMap() ? null : map);
		}

		function changeGradient() {
			var gradient = [
			    'rgba(0, 255, 255, 0)',
			    'rgba(0, 255, 255, 1)',
			    'rgba(0, 191, 255, 1)',
			    'rgba(0, 127, 255, 1)',
			    'rgba(0, 63, 255, 1)',
			    'rgba(0, 0, 255, 1)',
			    'rgba(0, 0, 223, 1)',
			    'rgba(0, 0, 191, 1)',
			    'rgba(0, 0, 159, 1)',
			    'rgba(0, 0, 127, 1)',
			    'rgba(63, 0, 91, 1)',
			    'rgba(127, 0, 63, 1)',
			    'rgba(191, 0, 31, 1)',
			    'rgba(255, 0, 0, 1)'
			]
			heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
		}

		function changeRadius() {
			heatmap.set('radius', heatmap.get('radius') ? null : 20);
		}

		function changeOpacity() {
			heatmap.set('opacity', heatmap.get('opacity') ? null : 0.2);
		}

		google.maps.event.addDomListener(window, 'load', initialize);

		</script>
	</head>


<body>
		<div id="panel">
			<div class="large-6 left">
			<button onclick="toggleHeatmap()">Toggle Heatmap</button>
			<button onclick="changeGradient()">Change gradient</button>
			<button onclick="changeRadius()">Change radius</button>
			<button onclick="changeOpacity()">Change opacity</button>
		</div>
		<div class="large-6 right">
			<select id="keys" class="large-8">
				<%
			    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	    		Query query = new Query("Keyword");
	    		PreparedQuery pq = datastore.prepare(query);

    			TreeSet<String> tree = new TreeSet<String>();

	    		for (Entity word : pq.asIterable())
	    		{
	    			tree.add((String)word.getProperty("key"));
	    		}
			
				Iterator<String> iterator = tree.iterator();
				while (iterator.hasNext())
				{
					String currentWord = iterator.next();
					%>
						<option value="<%=currentWord%>">
							<%=currentWord%>
						</option>
					<%
				}
				%>
			</select>
			<button onclick="selectKeyword()" class="large-4">Select Keyword</button>
		</div>
		</div>

		<div class="row" style="max-width:100% !important;">
			<div class="large-12">
				<div id="map-canvas"></div>
			</div>
		</div>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="../../dist/js/bootstrap.min.js"></script>
  </body>
</html>
