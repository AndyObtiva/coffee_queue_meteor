@Products = new Mongo.Collection("products")

Meteor.publish "products", => @Products
