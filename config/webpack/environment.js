const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

<<<<<<< HEAD
environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      jquery: 'jquery',
      'window.jQuery': 'jquery',
      Popper: ['popper.js', 'default'],
    })
)
=======
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

>>>>>>> get_cidr
module.exports = environment
