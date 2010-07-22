/*
 * Copyright (c) 2010. betterForm Project - http://www.betterform.de
 * Licensed under the terms of BSD License
 */

dojo.provide("betterform.ui.trigger.Button");

dojo.require("dijit._Widget");
dojo.require("dijit._Templated");
dojo.require("dijit.form.Button");
dojo.require("betterform.ui.ControlValue");

dojo.declare(
        "betterform.ui.trigger.Button",
        [betterform.ui.ControlValue, dijit.form.Button],
{
    buildRendering:function() {
        this.inherited(arguments);
        var imageSource = dojo.attr(this.srcNodeRef,"source");
        if(imageSource != undefined && imageSource !=""){
            var image = document.createElement("img");
            dojo.attr(image, "src",imageSource);
            this.iconNode.appendChild(image);
            this.showLabel = false;
        }
    },

   postMixInProperties:function() {
        this.inherited(arguments);
        this.applyProperties(dijit.byId(this.xfControlId), this.srcNodeRef);
    },

    getControlValue:function(){
        //console.debug("betterform.ui.trigger.Button.getControlValue", dojo.attr(this.domNode,"value"));
        return dojo.attr(this.domNode,"value");
    },

    _handleSetControlValue:function(value) {
        console.warn("TBD: betterform.ui.trigger.Button._handleSetControlValue: Value: ", value);        
    },

    onClick:function(e){
         // this.inherited(arguments);
         fluxProcessor.dispatchEvent(this.xfControlId);
    },
  _setLabel:function(value) {
      // console.debug("betterform.ui.trigger.Button._setLabel value:",value, " domNode: ",this.domNode);
      dojo.byId(this.id+"_label").innerHTML = value;
      
    }

});
