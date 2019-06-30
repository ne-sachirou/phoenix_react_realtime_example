import { Socket } from "phoenix";
import React, { createContext, useContext, useEffect, useReducer } from "react";
import ReactDOM from "react-dom";

const SocketContext = createContext();

function SocketProvider({ wsUrl, options, children }) {
  const socket = new Socket(wsUrl, { params: options });
  useEffect(() => {
    socket.connect();
  }, [options, wsUrl]);
  return (
    <SocketContext.Provider value={socket}>{children}</SocketContext.Provider>
  );
}

SocketProvider.defaultProps = {
  options: {}
};

function useChannel(channelTopic, reducer, initialState) {
  const socket = useContext(SocketContext);
  const [state, dispatch] = useReducer(reducer, initialState);
  useEffect(() => {
    const channel = socket.channel(channelTopic, {});
    channel.onMessage = (event, payload) => {
      dispatch({ event, payload });
      return payload;
    };
    channel
      .join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp);
      })
      .receive("error", resp => {
        console.error("Unable to join", resp);
      });
    return () => {
      channel.leave();
    };
  }, [channelTopic]);
  return state;
}

function counterReducer(state, { event, payload }) {
  switch (event) {
    case "count_up":
      return { ...state, count: payload.count };
    default:
      return state;
  }
}

function Counter(props) {
  const initialState = { count: 0 };
  const { count } = useChannel("room:lobby", counterReducer, initialState);
  return <div>(React) Count: {count}</div>;
}

export default function main() {
  ReactDOM.render(
    <SocketProvider wsUrl={"/socket"} options={{ token: window.userToken }}>
      <Counter />
    </SocketProvider>,
    document.getElementById("app")
  );
}
