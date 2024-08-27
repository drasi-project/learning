import React from 'react';
import {getConnection} from './connection-pool'

export default class ReactionResult extends React.Component {
  constructor(props) {
    super(props);
    this.mounted = false;
    this.sigRConn = getConnection(props.url);
    this.needsReload = !(props.noReload);
    let self = this;    
    
    this.onUpdate = item => {
      console.log("update: "+ JSON.stringify(item));
      if (self.props.onMessage)
        self.props.onMessage(item);

      if (item.seq) {
        self.state.seq = item.seq;
      }
        
      if (['i', 'u', 'd'].includes(item.op)) {
        const itemKey = self.getKey(self, item);
        if (item.op == 'd') {
          if (self.props.ignoreDeletes)
            return;
          delete self.state.data[itemKey];
        }
        else {
          self.state.data[itemKey] = item.payload.after;
        }
      }

      if (item.op == 'x') {
        switch (item.payload.kind) {
          case 'deleted':
            self.state.data = {};
            break;
        }
      }

      if (self.mounted) {
        self.setState({
          data: self.state.data,
          seq: self.state.seq
        });
      }
    };

    this.state = { data: {} };
  }

  componentDidMount() {
    let self = this;
    console.log("mount");
    this.sigRConn.started
      .then(result => {
        self.sigRConn.connection.on(self.props.queryId, self.onUpdate);
        if (self.needsReload) {
          self.reload();          
          self.needsReload = false;
        }
      });
    this.mounted = true;
  }

  reload() {
    console.log("requesting reload for " + this.props.queryId);
    let self = this;

    this.sigRConn.connection.stream("reload", this.props.queryId)
      .subscribe({
        next: item => {
          console.log(self.props.queryId + " reload next: " + JSON.stringify(item));
          switch (item['op']) {
            case 'h':
              self.state.data = {};
              self.state.seq = item.seq;
              break;
            case 'r':
              const itemKey = self.getKey(self, item);
              self.state.data[itemKey] = item.payload.after;
              if (self.props.onReloadItem) {
                self.props.onReloadItem(item.payload.after);
              }
              break;
          }
        },
        complete: () => {
          console.log(self.props.queryId + " reload complete");
          if (self.mounted) {
            self.setState({
              data: self.state.data,
              seq: self.state.seq
            });
          }
          console.log(self.props.queryId + " reload stream completed");
        },
        error: err => console.error(self.props.queryId + err)
      });
  }

  componentWillUnmount() {
    this.sigRConn.connection.off(this.props.queryId, this.onUpdate);
    this.mounted = false;
  }

  getKey(self, item) {    
    if (item.op == 'd' && item.payload.before)
      return self.props.itemKey(item.payload.before);
    return self.props.itemKey(item.payload.after);
  }

  render() {
    let self = this;
    let keys = Object.keys(this.state.data);
    
    if (self.props.sortBy) {
      keys = keys.sort((a, b) => {
        let aVal = self.state.data[a][self.props.sortBy];
        let bVal = self.state.data[b][self.props.sortBy];
        if (aVal < bVal) return -1;
        if (aVal > bVal) return 1;
        return 0;
      });
    }

    if (self.props.reverse)
      keys.reverse();    
    const listItems = keys.map((k) => {
        let child = React.Children.only(self.props.children);
        return React.cloneElement(child, _extends({ key: k }, this.state.data[k]));
      });
    return listItems;
  }
}

function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }