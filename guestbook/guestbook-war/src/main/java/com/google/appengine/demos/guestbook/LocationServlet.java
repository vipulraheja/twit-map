package com.google.appengine.demos.guestbook;

import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.CompositeFilter;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.memcache.*;

import java.io.IOException;
import java.util.Date;
import java.util.*;
import java.lang.*;
import java.util.logging.Level;
import org.json.*;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.*;

public class LocationServlet extends HttpServlet {
	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
	throws IOException 
{

	String word=(String)req.getParameter("keyword");
	System.out.println("I am here---" + word);
	ArrayList<Double> latitude= new ArrayList<Double>();
	ArrayList<Double> longitude= new ArrayList<Double>();
	ArrayList<ArrayList<Double>> value;
	MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	value = (ArrayList<ArrayList<Double>>) syncCache.get(word); // read from cache

	System.out.println("VALUE: " + value);

	if (value != null) 
	{
		latitude= value.get(0); 
		longitude= value.get(1);

		System.out.println("In memcache");
		System.out.println("lat " + latitude);
		System.out.println("lon " + longitude);
	}

	else
	{
		System.out.println("Not in memcache:");
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

		// ArrayList<Double> latitude = new ArrayList<Double>();
		// ArrayList<Double> longitude = new ArrayList<Double>();
		Filter keywordFilter = new FilterPredicate("key",FilterOperator.EQUAL,word);

		Query query = new Query("Keyword").setFilter(keywordFilter);

		PreparedQuery pq = datastore.prepare(query);
		for (Entity result : pq.asIterable()) {
			System.out.println(result.getProperty("lat"));
			System.out.println(result.getProperty("lon"));

			latitude.add((Double)result.getProperty("lat"));
			longitude.add((Double)result.getProperty("lon"));

		}
	
		value= new ArrayList<ArrayList<Double>>();
		value.add(latitude);
		value.add(longitude);
		syncCache.put(word, value);
	}

	System.out.println("FINAL VALUES ARE:");
	System.out.println("lat " + latitude);
	System.out.println("lon " + longitude);

	JSONObject obj= new JSONObject();
	obj.put("latitude",latitude);
	obj.put("longitude",longitude);
	String myString=obj.toString();

	//String myString = new JSONObject().put("latitude" :latitude, "longitude": longitude).toString();


	resp.setContentType("application/json");
	// resp.setCharacterEncoding("UTF-8");
	resp.getWriter().write(myString);



	// A bare bones StatusStreamHandler, which extends listener and gives some extra functionality

}
}
