@Orders = new Mongo.Collection("orders")

Meteor.publish "orders", => @Orders.find()
