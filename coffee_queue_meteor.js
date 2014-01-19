Orders = new Meteor.Collection("orders");
Products = new Meteor.Collection("products");
ProductOptions = new Meteor.Collection("productOptions");

if (Meteor.isClient) {
  Template.order.products = function() {
    return Products.find().fetch();
  }
  Template.order.productOptions = function() {
    var productName = Session.get("productName") || 'Filtered'
    return ProductOptions.find({productName: productName}).fetch();
  }

  Template.order.events({
    'change select#productName' : function (event) {
      Session.set("productName", $('select#productName').val());
    },
    // TODO support ENTER key submit of form (seems disabled in Meteor by default) [http://stackoverflow.com/questions/13010151/input-text-return-event-in-meteor]
    'click input[type=submit]' : function (event) {
      Orders.insert({
        name: $('input#name').val(),
        product: {
          name: $('select#productName').val()
        },
        productOption:  {
          name: $('select#productOptionName').val(),
          productName: $('select#productName').val()
        }
      });
    }
  });

  Template.orders.orders = function() {
    return Orders.find();
  }
}

if (Meteor.isServer) {
  Meteor.startup(function () {
//    Products.remove({})
//    ProductOptions.remove({})
    if (Products.find().count() === 0) {
      var names = {
          "Filtered": ["Large", "Medium", "Small"],
          "Latte": ["Regular", "Skim"],
          "Espresso": ["Single", "Double"],
          "Cappuccino": ["Standard"],
          "Mocha": ["Regular", "Regular Skim", "White", "White Skim", "Marble", "Marble Skim"],
          "Americano": ["Standard"]
      };
      for (var name in names) {
        Products.insert({name: name})
        options = names[name]
        for (var i = 0; i < options.length; i++) {
          ProductOptions.insert( {productName: name, name: options[i]} )
        }
      }
    }
  });
}
