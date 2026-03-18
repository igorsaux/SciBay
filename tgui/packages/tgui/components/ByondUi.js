/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { shallowDiffers } from "common/react";
import { debounce } from "common/timer";
import { Component, createRef } from "inferno";
import { createLogger } from "../logging";
import { computeBoxProps } from "./Box";

const logger = createLogger("ByondUi");

// Stack of currently allocated BYOND UI element ids.
const byondUiStack = [];

const createByondUiElement = (elementId) => {
  // Reserve an index in the stack
  const index = byondUiStack.length;
  byondUiStack.push(null);
  // Get a unique id
  const id = elementId || "byondui_" + index;
  logger.log(`allocated '${id}'`);
  // Return a control structure
  return {
    render: (params) => {
      logger.log(`rendering '${id}'`);
      byondUiStack[index] = id;
      Byond.winset(id, params);
    },
    unmount: () => {
      logger.log(`unmounting '${id}'`);
      byondUiStack[index] = null;
      Byond.winset(id, {
        parent: "",
      });
    },
  };
};

window.addEventListener("beforeunload", () => {
  // Cleanly unmount all visible UI elements
  for (let index = 0; index < byondUiStack.length; index++) {
    const id = byondUiStack[index];
    if (typeof id === "string") {
      logger.log(`unmounting '${id}' (beforeunload)`);
      byondUiStack[index] = null;
      Byond.winset(id, {
        parent: "",
      });
    }
  }
});

/**
 * Get the bounding box of the DOM element in display-pixels.
 */
const getBoundingBox = (element) => {
  const pixelRatio = window.devicePixelRatio ?? 1;
  const rect = element.getBoundingClientRect();
  return {
    pos: [rect.left * pixelRatio, rect.top * pixelRatio],
    size: [
      (rect.right - rect.left) * pixelRatio,
      (rect.bottom - rect.top) * pixelRatio,
    ],
  };
};

export class ByondUi extends Component {
  constructor(props) {
    super(props);
    this.containerRef = createRef();
    this.byondUiElement = createByondUiElement(props.params?.id);
    this.resizeObserver = null;
    this.handleResize = debounce(() => {
      this.forceUpdate();
    }, 100);
  }

  shouldComponentUpdate(nextProps) {
    const { params: prevParams = {}, ...prevRest } = this.props;
    const { params: nextParams = {}, ...nextRest } = nextProps;
    return (
      shallowDiffers(prevParams, nextParams) ||
      shallowDiffers(prevRest, nextRest)
    );
  }

  componentDidMount() {
    window.addEventListener("resize", this.handleResize);
    if (window.ResizeObserver && this.containerRef.current) {
      this.resizeObserver = new window.ResizeObserver(() => {
        this.handleResize();
      });
      this.resizeObserver.observe(this.containerRef.current);
    }
    this.componentDidUpdate();
    this.handleResize();
    requestAnimationFrame(() => {
      this.handleResize();
    });
  }

  componentDidUpdate() {
    const { params = {} } = this.props;
    const box = getBoundingBox(this.containerRef.current);
    logger.debug("bounding box", box);
    this.byondUiElement.render({
      parent: Byond.windowId,
      ...params,
      pos: box.pos[0] + "," + box.pos[1],
      size: box.size[0] + "x" + box.size[1],
    });
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.handleResize);
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
    this.byondUiElement.unmount();
  }

  render() {
    const { params, ...rest } = this.props;
    return (
      <div ref={this.containerRef} {...computeBoxProps(rest)}>
        {/* Filler */}
        <div style={{ "min-height": "22px" }} />
      </div>
    );
  }
}
