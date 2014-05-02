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
    $.extend(this, order)

  waiting: ->
    !@state

  ready: ->
    @state == 'ready'

  served: ->
    @state == 'served'

  fulfilled: ->
    !!@fulfilledAt

  fulfillmentTime: ->
    time = @fulfilledAt - @createdAt
    if (time == NaN) then Infinity else time

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

  Template.stats.averageWaitTimeForOrders = (orders) ->
    return 0 if orders.length == 0
    averageTime = 0
    count = 0
    _.each(orders, (order) ->
      oneHourAgo = 60.minutes.ago
      if order.fulfilledAt && order.createdAt && order.createdAt > oneHourAgo
        averageTime += (order.fulfillmentTime())
        count += 1
    )
    (averageTime / count) / 1000

  Template.stats.averageWaitTime = ->
    fulfilledOrders = Template.orders.fulfilledOrders()
    parseInt(Template.stats.averageWaitTimeForOrders(fulfilledOrders))

  Template.stats.fastestBarista = ->
    baristas = Baristas.find().fetch()
    _.each baristas, (barista) =>
      baristaOrders = Orders.find(baristaId: barista._id).fetch()
      customerOrders = Template.orders.customerOrders(baristaOrders)
      fastestOrder = _.min customerOrders, (customerOrder) -> customerOrder.fulfillmentTime()
      barista.fastestTime = if customerOrders.length then fastestOrder.fulfillmentTime() else 999999

    _.min baristas, (barista) -> barista.fastestTime


  Template.orders.customerOrders = (orders=null) ->
    orders = Orders.find().fetch() unless orders
    _.map(orders, (order) -> new CustomerOrder(order))

  Template.orders.ordersInProgress = ->
    _.filter(Template.orders.customerOrders(), (order) -> order.waiting())

  Template.orders.noOrdersInProgress = ->
    Template.orders.ordersInProgress().length == 0

  Template.orders.readyOrders = ->
    _.filter(Template.orders.customerOrders(), (order) -> order.ready())

  Template.orders.fulfilledOrders = ->
    _.filter(Template.orders.customerOrders(), (order) -> order.fulfilled())

  Template.orders.events({
    'click input[type=button]' : (event) ->
      customerId = $(event.target).data('id')
      order = Orders.findOne({_id: customerId})
      order = new CustomerOrder(order)
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
          fulfilledAt: fulfilledAt,
          baristaId: Meteor.userId()
        }
      )
  })

#  Template.loginButtons.events({
#    'click #login-buttons' : (event) ->
#      $('.main-lane.box').animate({height: 400})
#  })

if Meteor.isServer
  Meteor.startup ->
#    Products.remove({})
#    ProductOptions.remove({})
#    Orders.remove({})
#    Baristas.remove({})
    if Products.find().count() == 0
      names = {
          "Filtered": ["Large", "Medium", "Small"],
          "Latte": ["Regular", "Skim"],
          "Espresso": ["Single", "Double"],
          "Cappuccino": ["Standard"],
          "Mocha": ["Regular", "Regular Skim", "White", "White Skim", "Marble", "Marble Skim"],
          "Americano": ["Standard"],
          "Machiato": ["Regular", "Caramel"],
          "Frappucino": ["Regular", "Chocolate", "Vanilla"],
          "Cuban": ["Cortado", "Cortadito", "Cafe Con Leche"]
      };
      for name of names
        Products.insert({name: name})
        options = names[name]
        ProductOptions.insert(productName: name, name: option) for option in options