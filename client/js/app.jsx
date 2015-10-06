App = React.createClass({

  mixins: [ReactMeteorData],

  getMeteorData() {
    return {
      ordersInProgress: CustomerOrder.ordersInProgress(),
      readyOrders: CustomerOrder.readyOrders()
    }
  },

  render() {
    return (
      <div idName="order_list" className="main-lane">
        <div idName="waiting" className="step box">
          <h1>Waiting for Order</h1>
          <OrdersView key="WaitingOrders" orders={this.data.ordersInProgress} />
        </div>
        <div idName="ready" className="step box">
          <h1>Ready for Pickup</h1>
          <OrdersView key="ReadyOrders" orders={this.data.readyOrders} />
        </div>
      </div>
    );
  }
});
