Orders = new Meteor.Collection("orders")
Products = new Meteor.Collection("products")
ProductOptions = new Meteor.Collection("productOptions")
#TODO add collection data security
#Orders.allow(
#  remove: (userId, order) ->
#    true;
#);
@Orders = Meteor.orders = Orders
@Products = Meteor.products = Products
@ProductOptions = Meteor.productOptions = ProductOptions
Baristas = Meteor.users
formDescriptionObject = {
  id: "orderForm"
  fields:{
    name: {
      required: true
    },
  }
}
Mesosphere(formDescriptionObject)

class CustomerOrder
  constructor: (order) ->
    @order = order
    $.extend(this, @order)

  waiting: ->
    !@order.state

  ready: ->
    @order.state == 'ready'

  served: ->
    @order.state == 'served'

if Meteor.isClient
  Accounts.ui.config(passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL')

  Template.order.products = ->
    Products.find().fetch()

  Template.order.productOptions = ->
    productName = Session.get("productName") || 'Filtered'
    ProductOptions.find({productName: productName}).fetch()


  Template.order.events(
    'change select#productName' : (event) ->
      Session.set("productName", $('select#productName').val())
    ,
    # TODO support ENTER key submit of form (seems disabled in Meteor by default) [http://stackoverflow.com/questions/13010151/input-text-return-event-in-meteor]
    'click input[type=submit]' : (event) ->
      rawFormData = {
        name: $('input#name').val(),
        createdAt: new Date(),
        product: {
          name: $('select#productName').val()
        },
        productOption:  {
          name: $('select#productOptionName').val(),
          productName: $('select#productName').val()
        }
      }
      Mesosphere.orderForm.validate rawFormData, (errors, formData) ->
        if errors
          $('#orderForm span').addClass('error')
        else
          $('#orderForm span').removeClass('error')
          Orders.insert(
            rawFormData
          )


  )

  Template.stats.averageWaitTime = ->
    averageTime = 0
    count = 0
    _.each(Template.orders.servedOrders(), (order) ->
      oneHourAgo = 60.minutes.ago
      if order.fulfilledAt && order.createdAt && order.createdAt > oneHourAgo
        averageTime += (order.fulfilledAt - order.createdAt)
        count += 1
    )
    (averageTime / count) / 1000

  Template.orders.ordersInProgress = ->
    _.filter(_.map(Orders.find().fetch(), (order) ->
      new CustomerOrder(order)
    ), (order) ->
      order.waiting()
    )

  Template.orders.noOrdersInProgress = ->
    Template.orders.ordersInProgress().length == 0

  Template.orders.readyOrders = ->
    _.filter(_.map(Orders.find().fetch(), (order) ->
      new CustomerOrder(order)
    ), (order) ->
      order.ready()
    )

  Template.orders.servedOrders = ->
    _.filter(_.map(Orders.find().fetch(), (order) ->
      new CustomerOrder(order)
    ), (order) ->
      order.served()
    )

  Template.orders.events({
    'click input[type=button]' : (event) ->
      customerName = $(event.target).data('name')
      order = new CustomerOrder(Orders.findOne(name: customerName))
      newStatus = if order.waiting() then 'ready' else 'served'
      fulfilledAt = if order.waiting() then new Date() else order.fulfilledAt
      Orders.update(
        {_id: order._id},
        {
          name: order.name,
          product: order.product,
          productOption: order.productOption,
          createdAt: order.createdAt,
          state: newStatus,
          fulfilledAt: fulfilledAt
        }
      )
  })

if Meteor.isServer
  Meteor.startup ->
#    Products.remove({})
#    ProductOptions.remove({})
    Orders.remove({})
    if Products.find().count() == 0
      names = {
          "Filtered": ["Large", "Medium", "Small"],
          "Latte": ["Regular", "Skim"],
          "Espresso": ["Single", "Double"],
          "Cappuccino": ["Standard"],
          "Mocha": ["Regular", "Regular Skim", "White", "White Skim", "Marble", "Marble Skim"],
          "Americano": ["Standard"]
      };
      for name in names
        Products.insert({name: name})
        options = names[name]
        ProductOptions.insert(productName: name, name: option) for option in options