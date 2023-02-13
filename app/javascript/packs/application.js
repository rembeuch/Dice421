import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

require("@rails/ujs").start();
require("@rails/activestorage").start();
require("channels");
import 'plugins/sweet-alert-confirm';

const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
import "controllers"
