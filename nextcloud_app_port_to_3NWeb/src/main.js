// Recomendation of babeljs (https://babeljs.io/docs/en/babel-polyfill)
import 'core-js/stable'; // only stable feature also is possible with only `core-js`
import 'regenerator-runtime/runtime'; // To ensure that regeneratorRuntime is defined globally

import Vue from 'vue'
import App from './App.vue'
import router from './router.js'
import store from './store.js'

Vue.mixin({ methods: { t, n } })

export default new Vue({
	el: '#content',
	store,
	router,
	render: h => h(App),
})
