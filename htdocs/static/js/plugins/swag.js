(function(){var e,t,n,r,i,s=[].indexOf||function(e){for(var t=0,n=this.length;t<n;t++)if(t in this&&this[t]===e)return t;return-1};typeof window!="undefined"&&window!==null&&(n=window.Handlebars,window.Swag=r={}),typeof module!="undefined"&&module!==null&&(n=require("handlebars"),module.exports=r={}),r.Config={partialsPath:""},i={},i.toString=Object.prototype.toString,i.isUndefined=function(e){return e==="undefined"||i.toString.call(e)==="[object Function]"||e.hash!=null},i.safeString=function(e){return new n.SafeString(e)},i.trim=function(e){var t;return t=/\S/.test(" ")?/^[\s\xA0]+|[\s\xA0]+$/g:/^\s+|\s+$/g,e.toString().replace(t,"")},n.registerHelper("lowercase",function(e){return e.toLowerCase()}),n.registerHelper("uppercase",function(e){return e.toUpperCase()}),n.registerHelper("capitalizeFirst",function(e){return e.charAt(0).toUpperCase()+e.slice(1)}),n.registerHelper("capitalizeEach",function(e){return e.replace(/\w\S*/g,function(e){return e.charAt(0).toUpperCase()+e.substr(1)})}),n.registerHelper("titleize",function(e){var t,n,r,i;return n=e.replace(/[ \-_]+/g," "),i=n.match(/\w+/g),t=function(e){return e.charAt(0).toUpperCase()+e.slice(1)},function(){var e,n,s;s=[];for(e=0,n=i.length;e<n;e++)r=i[e],s.push(t(r));return s}().join(" ")}),n.registerHelper("sentence",function(e){return e.replace(/((?:\S[^\.\?\!]*)[\.\?\!]*)/g,function(e){return e.charAt(0).toUpperCase()+e.substr(1).toLowerCase()})}),n.registerHelper("reverse",function(e){return e.split("").reverse().join("")}),n.registerHelper("truncate",function(e,t,n){return i.isUndefined(n)&&(n=""),e.length>t?e.substring(0,t-n.length)+n:e}),n.registerHelper("center",function(e,t){var n,r;r="",n=0;while(n<t)r+="&nbsp;",n++;return""+r+e+r}),n.registerHelper("newLineToBr",function(e){return e.replace(/\n/g,"<br>")}),n.registerHelper("first",function(e,t){return i.isUndefined(t)?e[0]:e.slice(0,t)}),n.registerHelper("withFirst",function(e,t,n){var r,s;if(i.isUndefined(t))return n=t,n.fn(e[0]);e=e.slice(0,t),s="";for(r in e)s+=n.fn(e[r]);return s}),n.registerHelper("last",function(e,t){return i.isUndefined(t)?e[e.length-1]:e.slice(-t)}),n.registerHelper("withLast",function(e,t,n){var r,s;if(i.isUndefined(t))return n=t,n.fn(e[e.length-1]);e=e.slice(-t),s="";for(r in e)s+=n.fn(e[r]);return s}),n.registerHelper("after",function(e,t){return e.slice(t)}),n.registerHelper("withAfter",function(e,t,n){var r,i;e=e.slice(t),i="";for(r in e)i+=n.fn(e[r]);return i}),n.registerHelper("before",function(e,t){return e.slice(0,-t)}),n.registerHelper("withBefore",function(e,t,n){var r,i;e=e.slice(0,-t),i="";for(r in e)i+=n.fn(e[r]);return i}),n.registerHelper("join",function(e,t){return e.join(i.isUndefined(t)?" ":t)}),n.registerHelper("sort",function(e,t){return i.isUndefined(t)?e.sort():e.sort(function(e,n){return e[t]>n[t]})}),n.registerHelper("withSort",function(e,t,n){var r,s,o,u;s="";if(i.isUndefined(t)){n=t,e=e.sort();for(o=0,u=e.length;o<u;o++)r=e[o],s+=n.fn(r)}else{e=e.sort(function(e,n){return e[t]>n[t]});for(r in e)s+=n.fn(e[r])}return s}),n.registerHelper("length",function(e){return e.length}),n.registerHelper("lengthEqual",function(e,t,n){return e.length===t?n.fn(this):n.inverse(this)}),n.registerHelper("empty",function(e,t){return e.length<=0?t.fn(this):t.inverse(this)}),n.registerHelper("any",function(e,t){return e.length>0?t.fn(this):t.inverse(this)}),n.registerHelper("inArray",function(e,t,n){return e.indexOf(t)!==-1?n.fn(this):n.inverse(this)}),n.registerHelper("eachIndex",function(e,t){var r,i,s,o;o="",t.data!=null&&(r=n.createFrame(t.data));if(e&&e.length>0){i=0,s=e.length;while(i<s)r&&(r.index=i),e[i].index=i,o+=t.fn(e[i]),i++}else o=t.inverse(this);return o}),n.registerHelper("add",function(e,t){return e+t}),n.registerHelper("subtract",function(e,t){return e-t}),n.registerHelper("divide",function(e,t){return e/t}),n.registerHelper("multiply",function(e,t){return e*t}),n.registerHelper("floor",function(e){return Math.floor(e)}),n.registerHelper("ceil",function(e){return Math.ceil(e)}),n.registerHelper("round",function(e){return Math.round(e)}),n.registerHelper("toFixed",function(e,t){return i.isUndefined(t)&&(t=0),e.toFixed(t)}),n.registerHelper("toPrecision",function(e,t){return i.isUndefined(t)&&(t=1),e.toPrecision(t)}),n.registerHelper("toExponential",function(e,t){return i.isUndefined(t)&&(t=0),e.toExponential(t)}),n.registerHelper("toInt",function(e){return parseInt(e,10)}),n.registerHelper("toFloat",function(e){return parseFloat(e)}),n.registerHelper("addCommas",function(e){return e.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g,"$1,")}),n.registerHelper("equal",function(e,t,n){return e===t?n.fn(this):n.inverse(this)}),n.registerHelper("notEqual",function(e,t,n){return e!==t?n.fn(this):n.inverse(this)}),n.registerHelper("gt",function(e,t,n){return e>t?n.fn(this):n.inverse(this)}),n.registerHelper("gte",function(e,t,n){return e>=t?n.fn(this):n.inverse(this)}),n.registerHelper("lt",function(e,t,n){return e<t?n.fn(this):n.inverse(this)}),n.registerHelper("lte",function(e,t,n){return e<=t?n.fn(this):n.inverse(this)}),e={},e.padNumber=function(e,t,n){var r,i;typeof n=="undefined"&&(n="0"),r=t-String(e).length,i="";if(r>0)while(r--)i+=n;return i+e},e.dayOfYear=function(e){var t;return t=new Date(e.getFullYear(),0,1),Math.ceil((e-t)/864e5)},e.weekOfYear=function(e){var t;return t=new Date(e.getFullYear(),0,1),Math.ceil(((e-t)/864e5+t.getDay()+1)/7)},e.isoWeekOfYear=function(e){var t,n,r,i;return i=new Date(e.valueOf()),n=(e.getDay()+6)%7,i.setDate(i.getDate()-n+3),r=new Date(i.getFullYear(),0,4),t=(i-r)/864e5,1+Math.ceil(t/7)},e.tweleveHour=function(e){return e.getHours()>12?e.getHours()-12:e.getHours()},e.timeZoneOffset=function(t){var n,r;return n=-t.getTimezoneOffset()/60,r=e.padNumber(Math.abs(n),4),(n>0?"+":"-")+r},e.format=function(t,n){return n.replace(e.formats,function(n,r){switch(r){case"a":return e.abbreviatedWeekdays[t.getDay()];case"A":return e.fullWeekdays[t.getDay()];case"b":return e.abbreviatedMonths[t.getMonth()];case"B":return e.fullMonths[t.getMonth()];case"c":return t.toLocaleString();case"C":return Math.round(t.getFullYear()/100);case"d":return e.padNumber(t.getDate(),2);case"D":return e.format(t,"%m/%d/%y");case"e":return e.padNumber(t.getDate(),2," ");case"F":return e.format(t,"%Y-%m-%d");case"h":return e.format(t,"%b");case"H":return e.padNumber(t.getHours(),2);case"I":return e.padNumber(e.tweleveHour(t),2);case"j":return e.padNumber(e.dayOfYear(t),3);case"k":return e.padNumber(t.getHours(),2," ");case"l":return e.padNumber(e.tweleveHour(t),2," ");case"L":return e.padNumber(t.getMilliseconds(),3);case"m":return e.padNumber(t.getMonth()+1,2);case"M":return e.padNumber(t.getMinutes(),2);case"n":return"\n";case"p":return t.getHours()>11?"PM":"AM";case"P":return e.format(t,"%p").toLowerCase();case"r":return e.format(t,"%I:%M:%S %p");case"R":return e.format(t,"%H:%M");case"s":return t.getTime()/1e3;case"S":return e.padNumber(t.getSeconds(),2);case"t":return"	";case"T":return e.format(t,"%H:%M:%S");case"u":return t.getDay()===0?7:t.getDay();case"U":return e.padNumber(e.weekOfYear(t),2);case"v":return e.format(t,"%e-%b-%Y");case"V":return e.padNumber(e.isoWeekOfYear(t),2);case"W":return e.padNumber(e.weekOfYear(t),2);case"w":return e.padNumber(t.getDay(),2);case"x":return t.toLocaleDateString();case"X":return t.toLocaleTimeString();case"y":return String(t.getFullYear()).substring(2);case"Y":return t.getFullYear();case"z":return e.timeZoneOffset(t);default:return match}})},e.formats=/%(a|A|b|B|c|C|d|D|e|F|h|H|I|j|k|l|L|m|M|n|p|P|r|R|s|S|t|T|u|U|v|V|W|w|x|X|y|Y|z)/g,e.abbreviatedWeekdays=["Sun","Mon","Tue","Wed","Thur","Fri","Sat"],e.fullWeekdays=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],e.abbreviatedMonths=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],e.fullMonths=["January","February","March","April","May","June","July","August","September","October","November","December"],n.registerHelper("formatDate",function(t,n){return t=new Date(t),e.format(t,n)}),n.registerHelper("now",function(t){var n;return n=new Date,i.isUndefined(t)?n:e.format(n,t)}),n.registerHelper("timeago",function(e){var t,n;return e=new Date(e),n=Math.floor((new Date-e)/1e3),t=Math.floor(n/31536e3),t>1?""+t+" years ago":(t=Math.floor(n/2592e3),t>1?""+t+" months ago":(t=Math.floor(n/86400),t>1?""+t+" days ago":(t=Math.floor(n/3600),t>1?""+t+" hours ago":(t=Math.floor(n/60),t>1?""+t+" minutes ago":Math.floor(n)===0?"Just now":Math.floor(n)+" seconds ago"))))}),n.registerHelper("inflect",function(e,t,n,r){var s;return s=e>1||e===0?n:t,i.isUndefined(r)||r===!1?s:""+e+" "+s}),n.registerHelper("ordinalize",function(e){var t,n;t=Math.abs(Math.round(e));if(n=t%100,s.call([11,12,13],n)>=0)return""+e+"th";switch(t%10){case 1:return""+e+"st";case 2:return""+e+"nd";case 3:return""+e+"rd";default:return""+e+"th"}}),t={},t.parseAttributes=function(e){return Object.keys(e).map(function(t){return""+t+'="'+e[t]+'"'}).join(" ")},n.registerHelper("ul",function(e,n){return"<ul "+t.parseAttributes(n.hash)+">"+e.map(function(e){return"<li>"+n.fn(e)+"</li>"}).join("\n")+"</ul>"}),n.registerHelper("ol",function(e,n){return"<ol "+t.parseAttributes(n.hash)+">"+e.map(function(e){return"<li>"+n.fn(e)+"</li>"}).join("\n")+"</ol>"}),n.registerHelper("br",function(e,t){var n,r;n="<br>";if(!i.isUndefined(e)){r=0;while(r<e-1)n+="<br>",r++}return i.safeString(n)}),n.registerHelper("log",function(e){return console.log(e)}),n.registerHelper("debug",function(e){return console.log("Context: ",this),i.isUndefined(e)||console.log("Value: ",e),console.log("-----------------------------------------------")}),n.registerHelper("default",function(e,t){return e!=null?e:t}),n.registerHelper("partial",function(e,t){var s;return s=r.Config.partialsPath+e,t=i.isUndefined(t)?{}:t,n.partials[e]==null&&n.registerPartial(e,require(s)),i.safeString(n.partials[e](t))})}).call(this)