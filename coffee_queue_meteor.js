Orders = new Meteor.Collection("orders");

if (Meteor.isClient) {
  Template.order.greeting = function () {
    return "Welcome to coffee_queue_meteor.";
  };

//  Template.coffeeQueue.products = function() { ["Mocha", "Americano"] }

  Template.order.events({
    'click input[type=button]' : function (element) {
      // template data, if any, is available in 'this'
      if (typeof console !== 'undefined') {
        Orders.insert({name: $('input[type=text]').val()});
        console.log("Order has been placed");
      }
    }
  });

  Template.orders.orders = function() {
    return Orders.find();
  }
}

if (Meteor.isServer) {
  Meteor.startup(function () {
  });
}
