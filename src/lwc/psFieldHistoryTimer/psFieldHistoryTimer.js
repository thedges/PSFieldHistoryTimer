import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getFieldHistory
  from '@salesforce/apex/PSFieldHistoryTimerUtils.getFieldHistory';

const columns = [
    {label: 'Value', fieldName: 'value', type: 'text'},
    {label: 'Date', fieldName: 'createdDate', type: 'text'},
    {label: 'Duration', fieldName: 'duration', type: 'text'}
];

export default class PsFieldHistoryTimer extends LightningElement {
  @api recordId;
  @api icon;
  @api title;
  @api fieldName;
  @api hoursEscalated;
  @api completedState;
  @track timerVal;
  initialized = false;
  columns = columns;
  currDate;
  currValue;
  resp;

  @wire(getRecord, { recordId: '$recordId', fields: [ 'Id' ] })
  recordUpdated({data, error }) {
    if (this.initialized)
    {
      this.refreshData();
    }
  }

  get timerStyle() {

    if (!this.currDate) return "color: #0059b3"; 

    var now = new Date().getTime();
    var duration = (now - this.currDate) / (1000 * 60 * 60);

    if (this.completedState != null && (this.currValue == this.completedState))
    {
      this.timerVal = 'Complete';
      return "color: #008000"; 
    }
    else if (duration >= this.hoursEscalated)
    {
      return "color: #b30000"; 
    }
    else
    {
      return "color: #0059b3"; 
    }
  }

  get historyAvailable() {
    if (this.resp && this.resp.history && this.resp.history.length > 0)
    {
      return true;
    }
    return false;
  }

  get currentValue() {
    if (this.currValue == null || this.currValue == '')
    {
      return '<blank>';
    }

    return this.currValue;
  }


  connectedCallback () {
     this.refreshData();
  }

  refreshData() {
    var self = this;
    this.resp = null;

    getFieldHistory ({recordId: this.recordId, fieldApiName: this.fieldName})
    .then (result => {
      console.log('result=' + result);
      self.resp = JSON.parse(result);
      console.log('self.resp.currDate=' + self.resp.currDate);
      self.currDate = Date.parse(self.resp.currDate);
      self.currValue = self.resp.currValue;
      self.timerVal = self.resp.currDuration;
      console.log('self.currDate=' + self.currDate);

      if (self.completedState == null || (self.currValue != self.completedState))
      {
        console.log('setting timer...');
        self.setTimer();
      }

      self.initialized = true;
    })
    .catch (error => {
      self.handleError (error);
    });
  }

  setTimer () {
    var self = this;
    /*
    var currDate = new Date ('Sep 19, 2020 06:00:00').getTime ();
    currDate = new Date ().getTime ();
    */

    // Update the count down every 1 second
    var x = setInterval (function () {
      // Get todays date and time
      var now = new Date ().getTime ();

      // Find the distance between now an the count down date
      var distance = (now - self.currDate) / 1000;

      // Time calculations for days, hours, minutes and seconds
      /*
  var years = Math.floor (
    distance % (1000 * 60 * 60 * 24 * 365 * 10000000) / (1000 * 60 * 60 * 24 * 365)
  );
  
  var days = Math.floor (
    distance % (1000 * 60 * 60 * 24 * 365) / (1000 * 60 * 60 * 24)
  );
  var hours = Math.floor (
    distance % (1000 * 60 * 60 * 24) / (1000 * 60 * 60)
  );
  var minutes = Math.floor (distance % (1000 * 60 * 60) / (1000 * 60));
var seconds = Math.floor (distance % (1000 * 60) / 1000);
*/

      var years = Math.floor (distance / 31556926) % 10000000;
      var days = Math.floor (distance / 86400) % 365;
      var hours = Math.floor (distance / 3600) % 24;
      var minutes = Math.floor (distance / 60) % 60;
      var seconds = Math.floor (distance / 1) % 60;

      self.timerVal = self.genTimerVal (years, days, hours, minutes, seconds);
    }, 1000);
  }

  genTimerVal (years, days, hours, minutes, seconds) {
    var str;

    if (years != 0) str = years + 'y ';

    if (str) {
      str += days + 'd ';
    } else if (days != 0) {
      str = days + 'd ';
    }

    if (str) {
      str += hours + 'h ';
    } else if (hours != 0) {
      str = hours + 'h ';
    }

    if (str) {
      str += minutes + 'm ';
    } else if (minutes != 0) {
      str = minutes + 'm ';
    }

    if (str) {
      str += seconds + 's';
    } else {
      str = seconds + 's';
    }

    return str;
  }

  handleError (err) {
    console.log ('error=' + err);
    console.log ('type=' + typeof err);

    this.showSpinner = false;

    const event = new ShowToastEvent ({
      title: err.statusText,
      message: err,
      variant: 'error',
      mode: 'pester',
    });
    this.dispatchEvent (event);
  }
}