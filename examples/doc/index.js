var amqp = require('amqplib/callback_api');
amqp.connect(
  'amqp://root:[RABBITMQ_PASS]@[CNAME]:5672', // Replace this line with your connection string
  function (error0, connection) {
    if (error0) {
      throw error0;
    }
    connection.createChannel(function (error1, channel) {
      if (error1) {
        throw error1;
      }
      var queue = 'hello';
      var msg = 'Hello World!';
      channel.assertQueue(queue, {
        durable: false,
      });
      channel.sendToQueue(queue, Buffer.from(msg));
      console.log(' [x] Sent %s', msg);
    });
    setTimeout(function () {
      connection.close();
      process.exit(0);
    }, 500);
  }
);
