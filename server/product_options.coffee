@ProductOptions = new Mongo.Collection("productOptions")

Meteor.publish "productOptions", => @ProductOptions
