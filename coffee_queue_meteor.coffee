Orders = new Meteor.Collection("orders")
Products = new Meteor.Collection("products")
ProductOptions = new Meteor.Collection("productOptions")
Baristas = Meteor.usersme

class CustomerOrder
  constructor: (order) ->
    @order = order

  name: ->
    @order.name

  createdAt: ->
    @order.createdAt

  fulfilledAt: ->
    @order.fulfilledAt

  product: ->
    @order.product

  productOption: ->
    @order.productOption

  waiting: ->
    !@order.state

  ready: ->
    @order.state == 'ready'

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
      if $('input#name').checkValidity()
        Orders.insert(
          name: $('input#name').val(),
          createdAt: new Date(),
          product: {
            name: $('select#productName').val()
          },
          productOption:  {
            name: $('select#productOptionName').val(),
            productName: $('select#productName').val()
          }
        )
  )

  Template.stats.averageWaitTime = ->
    averageTime = 0
    count = 0
    _.each(Template.orders.readyOrders(), (order) ->
      if order.fulfilledAt() && order.createdAt()
        averageTime += (order.fulfilledAt() - order.createdAt())
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

  Template.orders.events({
    'click input[type=button][value=Fulfill]' : (event) ->
      customerName = $(event.target).attr('id')
      order = Orders.findOne(name: customerName)
      Orders.update(
        {_id: order._id},
        {
          name: order.name,
          product: order.product,
          productOption: order.productOption,
          createdAt: order.createdAt,
          state: 'ready',
          fulfilledAt: new Date()
        }
      )
  })

if Meteor.isServer
  Meteor.startup ->
#    Products.remove({})
#    ProductOptions.remove({})
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
