
`packages\tgui\components\AnimatedNumber.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp, toFixed } from "common/math";
import { Component } from "inferno";

const FPS = 20;
const Q = 0.5;

const isSafeNumber = (value) => {
  return (
    typeof value === "number" && Number.isFinite(value) && !Number.isNaN(value)
  );
};

export class AnimatedNumber extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: 0,
    };
    // Use provided initial state
    if (isSafeNumber(props.initial)) {
      this.state.value = props.initial;
    } else if (isSafeNumber(props.value)) {
      // Set initial state with value provided in props
      this.state.value = Number(props.value);
    }
  }

  tick() {
    const { props, state } = this;
    const currentValue = Number(state.value);
    const targetValue = Number(props.value);
    // Avoid poisoning our state with infinities and NaN
    if (!isSafeNumber(targetValue)) {
      return;
    }
    // Smooth the value using an exponential moving average
    const value = currentValue * Q + targetValue * (1 - Q);
    this.setState({ value });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), 1000 / FPS);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    const { props, state } = this;
    const { format, children } = props;
    const currentValue = state.value;
    const targetValue = props.value;
    // Directly display values which can't be animated
    if (!isSafeNumber(targetValue)) {
      return targetValue || null;
    }
    let formattedValue;
    // Use custom formatter
    if (format) {
      formattedValue = format(currentValue);
    } else {
      // Fix our animated precision at target value's precision.
      const fraction = String(targetValue).split(".")[1];
      const precision = fraction ? fraction.length : 0;
      formattedValue = toFixed(currentValue, clamp(precision, 0, 8));
    }
    // Use a custom render function
    if (typeof children === "function") {
      return children(formattedValue, currentValue);
    }
    return formattedValue;
  }
}

```

`packages\tgui\components\Autofocus.tsx`

```tsx
import { Component, createRef } from 'inferno';

export class Autofocus extends Component {
  ref = createRef<HTMLDivElement>();

  componentDidMount() {
    setTimeout(() => {
      this.ref.current?.focus();
    }, 1);
  }

  render() {
    return (
      <div ref={this.ref} tabIndex={-1}>
        {this.props.children}
      </div>
    );
  }
}

```

`packages\tgui\components\Blink.js`

```javascript
import { Component } from "inferno";

const DEFAULT_BLINKING_INTERVAL = 1000;
const DEFAULT_BLINKING_TIME = 1000;

export class Blink extends Component {
  constructor() {
    super();
    this.state = {
      hidden: false,
    };
  }

  createTimer() {
    const {
      interval = DEFAULT_BLINKING_INTERVAL,
      time = DEFAULT_BLINKING_TIME,
    } = this.props;

    clearInterval(this.interval);
    clearTimeout(this.timer);

    this.setState({
      hidden: false,
    });

    this.interval = setInterval(() => {
      this.setState({
        hidden: true,
      });

      this.timer = setTimeout(() => {
        this.setState({
          hidden: false,
        });
      }, time);
    }, interval + time);
  }

  componentDidMount() {
    this.createTimer();
  }

  componentDidUpdate(prevProps) {
    if (
      prevProps.interval !== this.props.interval ||
      prevProps.time !== this.props.time
    ) {
      this.createTimer();
    }
  }

  componentWillUnmount() {
    clearInterval(this.interval);
    clearTimeout(this.timer);
  }

  render(props) {
    return (
      <span
        style={{
          visibility: this.state.hidden ? "hidden" : "visible",
        }}
      >
        {props.children}
      </span>
    );
  }
}

```

`packages\tgui\components\BlockQuote.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { Box } from "./Box";

export const BlockQuote = (props) => {
  const { className, ...rest } = props;
  return <Box className={classes(["BlockQuote", className])} {...rest} />;
};

```

`packages\tgui\components\Box.tsx`

```tsx
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from "common/react";
import { createVNode, InfernoNode } from "inferno";
import { ChildFlags, VNodeFlags } from "inferno-vnode-flags";
import { CSS_COLORS } from "../constants";

export interface BoxProps {
  [key: string]: any;
  as?: string;
  className?: string | BooleanLike;
  children?: InfernoNode;
  position?: string | BooleanLike;
  overflow?: string | BooleanLike;
  overflowX?: string | BooleanLike;
  overflowY?: string | BooleanLike;
  top?: string | BooleanLike;
  bottom?: string | BooleanLike;
  left?: string | BooleanLike;
  right?: string | BooleanLike;
  width?: string | BooleanLike;
  minWidth?: string | BooleanLike;
  maxWidth?: string | BooleanLike;
  height?: string | BooleanLike;
  minHeight?: string | BooleanLike;
  maxHeight?: string | BooleanLike;
  fontSize?: string | BooleanLike;
  fontFamily?: string;
  lineHeight?: string | BooleanLike;
  opacity?: number;
  textAlign?: string | BooleanLike;
  verticalAlign?: string | BooleanLike;
  inline?: BooleanLike;
  bold?: BooleanLike;
  italic?: BooleanLike;
  nowrap?: BooleanLike;
  preserveWhitespace?: BooleanLike;
  m?: string | BooleanLike;
  mx?: string | BooleanLike;
  my?: string | BooleanLike;
  mt?: string | BooleanLike;
  mb?: string | BooleanLike;
  ml?: string | BooleanLike;
  mr?: string | BooleanLike;
  p?: string | BooleanLike;
  px?: string | BooleanLike;
  py?: string | BooleanLike;
  pt?: string | BooleanLike;
  pb?: string | BooleanLike;
  pl?: string | BooleanLike;
  pr?: string | BooleanLike;
  color?: string | BooleanLike;
  textColor?: string | BooleanLike;
  backgroundColor?: string | BooleanLike;
  fillPositionedParent?: boolean;
}

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = (value: unknown): string | undefined => {
  if (typeof value === "string") {
    // Transparently convert pixels into rem units
    if (value.endsWith("px")) {
      return parseFloat(value) / 12 + "rem";
    }
    return value;
  }
  if (typeof value === "number") {
    return value + "rem";
  }
};

/**
 * Same as `unit`, but half the size for integers numbers.
 */
export const halfUnit = (value: unknown): string | undefined => {
  if (typeof value === "string") {
    return unit(value);
  }
  if (typeof value === "number") {
    return unit(value * 0.5);
  }
};

const isColorCode = (str: unknown) => !isColorClass(str);

const isColorClass = (str: unknown): boolean => {
  if (typeof str === "string") {
    return CSS_COLORS.includes(str);
  }
};

const mapRawPropTo = (attrName) => (style, value) => {
  if (typeof value === "number" || typeof value === "string") {
    style[attrName] = value;
  }
};

const mapUnitPropTo = (attrName, unit) => (style, value) => {
  if (typeof value === "number" || typeof value === "string") {
    style[attrName] = unit(value);
  }
};

const mapBooleanPropTo = (attrName, attrValue) => (style, value) => {
  if (value) {
    style[attrName] = attrValue;
  }
};

const mapDirectionalUnitPropTo = (attrName, unit, dirs) => (style, value) => {
  if (typeof value === "number" || typeof value === "string") {
    for (let i = 0; i < dirs.length; i++) {
      style[attrName + "-" + dirs[i]] = unit(value);
    }
  }
};

const mapColorPropTo = (attrName) => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

const styleMapperByPropName = {
  // Direct mapping
  position: mapRawPropTo("position"),
  overflow: mapRawPropTo("overflow"),
  overflowX: mapRawPropTo("overflow-x"),
  overflowY: mapRawPropTo("overflow-y"),
  top: mapUnitPropTo("top", unit),
  bottom: mapUnitPropTo("bottom", unit),
  left: mapUnitPropTo("left", unit),
  right: mapUnitPropTo("right", unit),
  width: mapUnitPropTo("width", unit),
  minWidth: mapUnitPropTo("min-width", unit),
  maxWidth: mapUnitPropTo("max-width", unit),
  height: mapUnitPropTo("height", unit),
  minHeight: mapUnitPropTo("min-height", unit),
  maxHeight: mapUnitPropTo("max-height", unit),
  fontSize: mapUnitPropTo("font-size", unit),
  fontFamily: mapRawPropTo("font-family"),
  lineHeight: (style, value) => {
    if (typeof value === "number") {
      style["line-height"] = value;
    } else if (typeof value === "string") {
      style["line-height"] = unit(value);
    }
  },
  opacity: mapRawPropTo("opacity"),
  textAlign: mapRawPropTo("text-align"),
  verticalAlign: mapRawPropTo("vertical-align"),
  // Boolean props
  inline: mapBooleanPropTo("display", "inline-block"),
  bold: mapBooleanPropTo("font-weight", "bold"),
  italic: mapBooleanPropTo("font-style", "italic"),
  nowrap: mapBooleanPropTo("white-space", "nowrap"),
  preserveWhitespace: mapBooleanPropTo("white-space", "pre-wrap"),
  // Margins
  m: mapDirectionalUnitPropTo("margin", halfUnit, [
    "top",
    "bottom",
    "left",
    "right",
  ]),
  mx: mapDirectionalUnitPropTo("margin", halfUnit, ["left", "right"]),
  my: mapDirectionalUnitPropTo("margin", halfUnit, ["top", "bottom"]),
  mt: mapUnitPropTo("margin-top", halfUnit),
  mb: mapUnitPropTo("margin-bottom", halfUnit),
  ml: mapUnitPropTo("margin-left", halfUnit),
  mr: mapUnitPropTo("margin-right", halfUnit),
  // Margins
  p: mapDirectionalUnitPropTo("padding", halfUnit, [
    "top",
    "bottom",
    "left",
    "right",
  ]),
  px: mapDirectionalUnitPropTo("padding", halfUnit, ["left", "right"]),
  py: mapDirectionalUnitPropTo("padding", halfUnit, ["top", "bottom"]),
  pt: mapUnitPropTo("padding-top", halfUnit),
  pb: mapUnitPropTo("padding-bottom", halfUnit),
  pl: mapUnitPropTo("padding-left", halfUnit),
  pr: mapUnitPropTo("padding-right", halfUnit),
  // Color props
  color: mapColorPropTo("color"),
  textColor: mapColorPropTo("color"),
  backgroundColor: mapColorPropTo("background-color"),
  // Utility props
  fillPositionedParent: (style, value) => {
    if (value) {
      style.position = "absolute";
      style.top = 0;
      style.bottom = 0;
      style.left = 0;
      style.right = 0;
    }
  },
};

export const computeBoxProps = (props: BoxProps) => {
  const computedProps: HTMLAttributes<any> = {};
  const computedStyles = {};
  // Compute props
  for (const propName of Object.keys(props)) {
    if (propName === "style") {
      continue;
    }
    const propValue = props[propName];
    const mapPropToStyle = styleMapperByPropName[propName];
    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    } else {
      computedProps[propName] = propValue;
    }
  }
  // Concatenate styles
  let style = "";
  for (const attrName of Object.keys(computedStyles)) {
    const attrValue = computedStyles[attrName];
    style += attrName + ":" + attrValue + ";";
  }
  if (props.style) {
    for (const attrName of Object.keys(props.style)) {
      const attrValue = props.style[attrName];
      style += attrName + ":" + attrValue + ";";
    }
  }
  if (style.length > 0) {
    computedProps.style = style;
  }
  return computedProps;
};

export const computeBoxClassName = (props: BoxProps) => {
  const color = props.textColor || props.color;
  const backgroundColor = props.backgroundColor;
  return classes([
    isColorClass(color) && "color-" + color,
    isColorClass(backgroundColor) && "color-bg-" + backgroundColor,
  ]);
};

export const Box = (props: BoxProps) => {
  const { as = "div", className, children, ...rest } = props;
  // Render props
  if (typeof children === "function") {
    return children(computeBoxProps(props));
  }
  const computedClassName =
    typeof className === "string"
      ? className + " " + computeBoxClassName(rest)
      : computeBoxClassName(rest);
  const computedProps = computeBoxProps(rest);
  // Render a wrapper element
  return createVNode(
    VNodeFlags.HtmlElement,
    as,
    computedClassName,
    children,
    ChildFlags.UnknownChildren,
    computedProps
  );
};

Box.defaultHooks = pureComponentHooks;

```

`packages\tgui\components\Button.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from "common/keycodes";
import { classes, pureComponentHooks } from "common/react";
import { Component, createRef } from "inferno";
import { createLogger } from "../logging";
import { Box, computeBoxClassName, computeBoxProps } from "./Box";
import { Icon } from "./Icon";
import { Tooltip } from "./Tooltip";

const logger = createLogger("Button");

export const Button = (props) => {
  const {
    className,
    fluid,
    icon,
    iconRotation,
    iconSpin,
    iconColor,
    iconPosition,
    color,
    disabled,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    compact,
    circular,
    content,
    children,
    onclick,
    onClick,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  // A warning about the lowercase onclick
  if (onclick) {
    logger.warn(
      "Lowercase 'onclick' is not supported on Button and lowercase" +
        " prop names are discouraged in general. Please use a camelCase" +
        "'onClick' instead and read: " +
        "https://infernojs.org/docs/guides/event-handling",
    );
  }
  let buttonContent = (
    <div
      className={classes([
        "Button",
        fluid && "Button--fluid",
        disabled && "Button--disabled",
        selected && "Button--selected",
        hasContent && "Button--hasContent",
        ellipsis && "Button--ellipsis",
        circular && "Button--circular",
        compact && "Button--compact",
        iconPosition && "Button--iconPosition--" + iconPosition,
        color && typeof color === "string"
          ? "Button--color--" + color
          : "Button--color--default",
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={!disabled && "0"}
      onClick={(e) => {
        if (!disabled && onClick) {
          onClick(e);
        }
      }}
      onKeyDown={(e) => {
        const keyCode = window.event ? e.which : e.keyCode;
        // Simulate a click when pressing space or enter.
        if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
          e.preventDefault();
          if (!disabled && onClick) {
            onClick(e);
          }
          return;
        }
        // Refocus layout on pressing escape.
        if (keyCode === KEY_ESCAPE) {
          e.preventDefault();
        }
      }}
      {...computeBoxProps(rest)}
    >
      {icon && iconPosition !== "right" && (
        <Icon
          name={icon}
          color={iconColor}
          rotation={iconRotation}
          spin={iconSpin}
        />
      )}
      {content}
      {children}
      {icon && iconPosition === "right" && (
        <Icon
          name={icon}
          color={iconColor}
          rotation={iconRotation}
          spin={iconSpin}
        />
      )}
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
};

export const ButtonLink = (props) => {
  return Button({
    ...props,
    className: "Button--link",
  });
};

Button.Link = ButtonLink;

export const ButtonLabel = (props) => {
  return Button({
    ...props,
    className: "Button--label",
  });
};

Button.Label = ButtonLabel;

export const ButtonSegmented = (props) => {
  return Button({
    ...props,
    className: "Button--segmented",
  });
};

Button.Segmented = ButtonSegmented;

Button.defaultHooks = pureComponentHooks;

export const ButtonCheckbox = (props) => {
  const { checked, ...rest } = props;
  return (
    <Button
      color="transparent"
      icon={checked ? "check-square-o" : "square-o"}
      selected={checked}
      {...rest}
    />
  );
};

Button.Checkbox = ButtonCheckbox;

export class ButtonConfirm extends Component {
  constructor() {
    super();
    this.state = {
      clickedOnce: false,
    };
    this.handleClick = () => {
      if (this.state.clickedOnce) {
        this.setClickedOnce(false);
      }
    };
  }

  setClickedOnce(clickedOnce) {
    this.setState({
      clickedOnce,
    });
    if (clickedOnce) {
      setTimeout(() => window.addEventListener("click", this.handleClick));
    } else {
      window.removeEventListener("click", this.handleClick);
    }
  }

  render() {
    const {
      confirmContent = "Confirm?",
      confirmColor = "bad",
      confirmIcon,
      icon,
      color,
      content,
      onClick,
      ...rest
    } = this.props;
    return (
      <Button
        content={this.state.clickedOnce ? confirmContent : content}
        icon={this.state.clickedOnce ? confirmIcon : icon}
        color={this.state.clickedOnce ? confirmColor : color}
        onClick={() =>
          this.state.clickedOnce ? onClick() : this.setClickedOnce(true)
        }
        {...rest}
      />
    );
  }
}

Button.Confirm = ButtonConfirm;

export class ButtonInput extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      inInput: false,
    };
  }

  setInInput(inInput) {
    this.setState({
      inInput,
    });
    if (this.inputRef) {
      const input = this.inputRef.current;
      if (inInput) {
        input.value = this.props.currentValue || "";
        try {
          input.focus();
          input.select();
        } catch {}
      }
    }
  }

  commitResult(e) {
    if (this.inputRef) {
      const input = this.inputRef.current;
      const hasValue = input.value !== "";
      if (hasValue) {
        this.props.onCommit(e, input.value);
      } else {
        if (!this.props.defaultValue) {
          return;
        }
        this.props.onCommit(e, this.props.defaultValue);
      }
    }
  }

  render() {
    const {
      fluid,
      content,
      icon,
      iconRotation,
      iconSpin,
      tooltip,
      tooltipPosition,
      color = "default",
      placeholder,
      maxLength,
      ...rest
    } = this.props;

    let buttonContent = (
      <Box
        className={classes([
          "Button",
          fluid && "Button--fluid",
          "Button--color--" + color,
        ])}
        {...rest}
        onClick={() => this.setInInput(true)}
      >
        {icon && <Icon name={icon} rotation={iconRotation} spin={iconSpin} />}
        <div>{content}</div>
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            display: !this.state.inInput ? "none" : undefined,
            "text-align": "left",
          }}
          onBlur={(e) => {
            if (!this.state.inInput) {
              return;
            }
            this.setInInput(false);
            this.commitResult(e);
          }}
          onKeyDown={(e) => {
            if (e.keyCode === KEY_ENTER) {
              this.setInInput(false);
              this.commitResult(e);
              return;
            }
            if (e.keyCode === KEY_ESCAPE) {
              this.setInInput(false);
            }
          }}
        />
      </Box>
    );

    if (tooltip) {
      buttonContent = (
        <Tooltip content={tooltip} position={tooltipPosition}>
          {buttonContent}
        </Tooltip>
      );
    }

    return buttonContent;
  }
}

Button.Input = ButtonInput;

```

`packages\tgui\components\ByondUi.js`

```javascript
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
    this.componentDidUpdate();
    this.handleResize();
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

```

`packages\tgui\components\Chart.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { map, zipWith } from "common/collections";
import { pureComponentHooks } from "common/react";
import { Component, createRef } from "inferno";
import { Box } from "./Box";

const normalizeData = (data, scale, rangeX, rangeY) => {
  if (data.length === 0) {
    return [];
  }
  const min = zipWith(Math.min)(...data);
  const max = zipWith(Math.max)(...data);
  if (rangeX !== undefined) {
    min[0] = rangeX[0];
    max[0] = rangeX[1];
  }
  if (rangeY !== undefined) {
    min[1] = rangeY[0];
    max[1] = rangeY[1];
  }
  const normalized = map((point) => {
    return zipWith((value, min, max, scale) => {
      return ((value - min) / (max - min)) * scale;
    })(point, min, max, scale);
  })(data);
  return normalized;
};

const dataToPolylinePoints = (data) => {
  let points = "";
  for (let i = 0; i < data.length; i++) {
    const point = data[i];
    points += point[0] + "," + point[1] + " ";
  }
  return points;
};

class LineChart extends Component {
  constructor(props) {
    super(props);
    this.ref = createRef();
    this.state = {
      // Initial guess
      viewBox: [600, 200],
    };
    this.handleResize = () => {
      const element = this.ref.current;
      this.setState({
        viewBox: [element.offsetWidth, element.offsetHeight],
      });
    };
  }

  componentDidMount() {
    window.addEventListener("resize", this.handleResize);
    this.handleResize();
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.handleResize);
  }

  render() {
    const {
      data = [],
      rangeX,
      rangeY,
      fillColor = "none",
      strokeColor = "#ffffff",
      strokeWidth = 2,
      ...rest
    } = this.props;
    const { viewBox } = this.state;
    const normalized = normalizeData(data, viewBox, rangeX, rangeY);
    // Push data outside viewBox and form a fillable polygon
    if (normalized.length > 0) {
      const first = normalized[0];
      const last = normalized[normalized.length - 1];
      normalized.push([viewBox[0] + strokeWidth, last[1]]);
      normalized.push([viewBox[0] + strokeWidth, -strokeWidth]);
      normalized.push([-strokeWidth, -strokeWidth]);
      normalized.push([-strokeWidth, first[1]]);
    }
    const points = dataToPolylinePoints(normalized);
    return (
      <Box position="relative" {...rest}>
        {(props) => (
          <div ref={this.ref} {...props}>
            <svg
              viewBox={`0 0 ${viewBox[0]} ${viewBox[1]}`}
              preserveAspectRatio="none"
              style={{
                position: "absolute",
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                overflow: "hidden",
              }}
            >
              <polyline
                transform={`scale(1, -1) translate(0, -${viewBox[1]})`}
                fill={fillColor}
                stroke={strokeColor}
                strokeWidth={strokeWidth}
                points={points}
              />
            </svg>
          </div>
        )}
      </Box>
    );
  }
}

LineChart.defaultHooks = pureComponentHooks;

const Stub = (props) => null;

export const Chart = {
  Line: LineChart,
};

```

`packages\tgui\components\Collapsible.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Component } from "inferno";
import { Box } from "./Box";
import { Button } from "./Button";

export class Collapsible extends Component {
  constructor(props) {
    super(props);
    const { open } = props;
    this.state = {
      open: open || false,
    };
  }

  render() {
    const { props } = this;
    const { open } = this.state;
    const { children, color = "default", title, buttons, ...rest } = props;
    return (
      <Box mb={1}>
        <div className="Table">
          <div className="Table__cell">
            <Button
              fluid
              color={color}
              icon={open ? "chevron-down" : "chevron-right"}
              onClick={() => this.setState({ open: !open })}
              {...rest}
            >
              {title}
            </Button>
          </div>
          {buttons && (
            <div className="Table__cell Table__cell--collapsing">{buttons}</div>
          )}
        </div>
        {open && <Box mt={1}>{children}</Box>}
      </Box>
    );
  }
}

```

`packages\tgui\components\ColorBox.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";

export const ColorBox = (props) => {
  const { content, children, className, color, backgroundColor, ...rest } =
    props;
  rest.color = content ? null : "transparent";
  rest.backgroundColor = color || backgroundColor;
  return (
    <div
      className={classes(["ColorBox", className, computeBoxClassName(rest)])}
      {...computeBoxProps(rest)}
    >
      {content || "."}
    </div>
  );
};

ColorBox.defaultHooks = pureComponentHooks;

```

`packages\tgui\components\Dimmer.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { Box } from "./Box";

export const Dimmer = (props) => {
  const { className, children, ...rest } = props;
  return (
    <Box className={classes(["Dimmer", className])} {...rest}>
      <div className="Dimmer__inner">{children}</div>
    </Box>
  );
};

```

`packages\tgui\components\Divider.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";

export const Divider = (props) => {
  const { vertical, hidden } = props;
  return (
    <div
      className={classes([
        "Divider",
        hidden && "Divider--hidden",
        vertical ? "Divider--vertical" : "Divider--horizontal",
      ])}
    />
  );
};

```

`packages\tgui\components\DraggableControl.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp } from "common/math";
import { pureComponentHooks } from "common/react";
import { Component, createRef } from "inferno";
import { AnimatedNumber } from "./AnimatedNumber";

const DEFAULT_UPDATE_RATE = 400;

/**
 * Reduces screen offset to a single number based on the matrix provided.
 */
const getScalarScreenOffset = (e, matrix) => {
  return e.screenX * matrix[0] + e.screenY * matrix[1];
};

export class DraggableControl extends Component {
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      value: props.value,
      dragging: false,
      editing: false,
      internalValue: null,
      origin: null,
      suppressingFlicker: false,
    };

    // Suppresses flickering while the value propagates through the backend
    this.flickerTimer = null;
    this.suppressFlicker = () => {
      const { suppressFlicker } = this.props;
      if (suppressFlicker > 0) {
        this.setState({
          suppressingFlicker: true,
        });
        clearTimeout(this.flickerTimer);
        this.flickerTimer = setTimeout(
          () =>
            this.setState({
              suppressingFlicker: false,
            }),
          suppressFlicker
        );
      }
    };

    this.handleDragStart = (e) => {
      const { value, dragMatrix } = this.props;
      const { editing } = this.state;
      if (editing) {
        return;
      }
      document.body.style["pointer-events"] = "none";
      this.ref = e.target;
      this.setState({
        dragging: false,
        origin: getScalarScreenOffset(e, dragMatrix),
        value,
        internalValue: value,
      });
      this.timer = setTimeout(() => {
        this.setState({
          dragging: true,
        });
      }, 250);
      this.dragInterval = setInterval(() => {
        const { dragging, value } = this.state;
        const { onDrag } = this.props;
        if (dragging && onDrag) {
          onDrag(e, value);
        }
      }, this.props.updateRate || DEFAULT_UPDATE_RATE);
      document.addEventListener("mousemove", this.handleDragMove);
      document.addEventListener("mouseup", this.handleDragEnd);
    };

    this.handleDragMove = (e) => {
      const { minValue, maxValue, step, stepPixelSize, dragMatrix } =
        this.props;
      this.setState((prevState) => {
        const state = { ...prevState };
        const offset = getScalarScreenOffset(e, dragMatrix) - state.origin;
        if (prevState.dragging) {
          const stepOffset = Number.isFinite(minValue) ? minValue % step : 0;
          // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)
          state.internalValue = clamp(
            state.internalValue + (offset * step) / stepPixelSize,
            minValue - step,
            maxValue + step
          );
          // Clamp the final value
          state.value = clamp(
            state.internalValue - (state.internalValue % step) + stepOffset,
            minValue,
            maxValue
          );
          state.origin = getScalarScreenOffset(e, dragMatrix);
        } else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = (e) => {
      const { onChange, onDrag } = this.props;
      const { dragging, value, internalValue } = this.state;
      document.body.style["pointer-events"] = "auto";
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      this.setState({
        dragging: false,
        editing: !dragging,
        origin: null,
      });
      document.removeEventListener("mousemove", this.handleDragMove);
      document.removeEventListener("mouseup", this.handleDragEnd);
      if (dragging) {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, value);
        }
        if (onDrag) {
          onDrag(e, value);
        }
      } else if (this.inputRef) {
        const input = this.inputRef.current;
        input.value = internalValue;
        // IE8: Dies when trying to focus a hidden element
        // (Error: Object does not support this action)
        try {
          input.focus();
          input.select();
        } catch {}
      }
    };
  }

  render() {
    const {
      dragging,
      editing,
      value: intermediateValue,
      suppressingFlicker,
    } = this.state;
    const {
      animated,
      value,
      unit,
      minValue,
      maxValue,
      unclamped,
      format,
      onChange,
      onDrag,
      children,
      // Input props
      height,
      lineHeight,
      fontSize,
    } = this.props;
    let displayValue = value;
    if (dragging || suppressingFlicker) {
      displayValue = intermediateValue;
    }
    // Setup a display element
    // Shows a formatted number based on what we are currently doing
    // with the draggable surface.
    const renderDisplayElement = (value) => value + (unit ? " " + unit : "");
    const displayElement =
      (animated && !dragging && !suppressingFlicker && (
        <AnimatedNumber value={displayValue} format={format}>
          {renderDisplayElement}
        </AnimatedNumber>
      )) ||
      renderDisplayElement(format ? format(displayValue) : displayValue);
    // Setup an input element
    // Handles direct input via the keyboard
    const inputElement = (
      <input
        ref={this.inputRef}
        className="NumberInput__input"
        style={{
          display: !editing ? "none" : undefined,
          height: height,
          "line-height": lineHeight,
          "font-size": fontSize,
        }}
        onBlur={(e) => {
          if (!editing) {
            return;
          }
          let value;
          if (unclamped) {
            value = parseFloat(e.target.value);
          } else {
            value = clamp(parseFloat(e.target.value), minValue, maxValue);
          }
          if (Number.isNaN(value)) {
            this.setState({
              editing: false,
            });
            return;
          }
          this.setState({
            editing: false,
            value,
          });
          this.suppressFlicker();
          if (onChange) {
            onChange(e, value);
          }
          if (onDrag) {
            onDrag(e, value);
          }
        }}
        onKeyDown={(e) => {
          if (e.keyCode === 13) {
            let value;
            if (unclamped) {
              value = parseFloat(e.target.value);
            } else {
              value = clamp(parseFloat(e.target.value), minValue, maxValue);
            }
            if (Number.isNaN(value)) {
              this.setState({
                editing: false,
              });
              return;
            }
            this.setState({
              editing: false,
              value,
            });
            this.suppressFlicker();
            if (onChange) {
              onChange(e, value);
            }
            if (onDrag) {
              onDrag(e, value);
            }
            return;
          }
          if (e.keyCode === 27) {
            this.setState({
              editing: false,
            });
          }
        }}
      />
    );
    // Return a part of the state for higher-level components to use.
    return children({
      dragging,
      editing,
      value,
      displayValue,
      displayElement,
      inputElement,
      handleDragStart: this.handleDragStart,
    });
  }
}

DraggableControl.defaultHooks = pureComponentHooks;
DraggableControl.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  stepPixelSize: 1,
  suppressFlicker: 50,
  dragMatrix: [1, 0],
};

```

`packages\tgui\components\Dropdown.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { Component } from "inferno";
import { Box } from "./Box";
import { Icon } from "./Icon";

export class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected,
    };
  }

  componentDidUpdate(prevProps) {
    if (prevProps.selected !== this.props.selected) {
      this.setState({ selected: this.props.selected });
    }
  }

  render() {
    const {
      icon,
      iconRotation,
      iconSpin,
      color = "default",
      // over / noscroll retained for API compat — unused (native select handles direction/scroll)
      over,
      noscroll,
      nochevron,
      width,
      onClick,
      selected: _selected,
      disabled,
      displayText,
      fluid,
      options = [],
      onSelected,
      ...boxProps
    } = this.props;
    const { className, ...rest } = boxProps;

    const currentSelected = this.state.selected || "";
    // "Action" dropdown: displayText is a placeholder (not a real selection).
    // After picking, the visible face reverts to displayText.
    const isAction =
      displayText !== undefined && !options.includes(currentSelected);
    // "Reselectable" mode: native select always sits at a sentinel value so
    // clicking the already-selected item still fires onChange.
    const { reselectable } = this.props;
    const usesSentinel = isAction || reselectable;

    return (
      <Box
        className={classes(["Dropdown", className])}
        width={fluid ? "100%" : width}
        {...rest}
      >
        {/* Styled visible face — pointer-events:none so clicks reach the native select */}
        <div
          className={classes([
            "Dropdown__control",
            "Button",
            "Button--color--" + color,
            disabled && "Button--disabled",
            fluid && "Button--fluid",
          ])}
        >
          {icon && (
            <Icon name={icon} rotation={iconRotation} spin={iconSpin} mr={1} />
          )}
          <span className="Dropdown__selected-text">
            {displayText || currentSelected}
          </span>
          {!nochevron && (
            <span className="Dropdown__arrow-button">
              <Icon name="chevron-down" />
            </span>
          )}
        </div>
        {/*
          Invisible native select covers the entire control area.
          The browser renders its own dropdown — no JS positioning, no clipping issues,
          no scroll hacks. Works correctly in BYOND's embedded browser.
        */}
        <select
          className="Dropdown__native"
          disabled={!!disabled}
          value={usesSentinel ? "" : currentSelected}
          onChange={(e) => {
            const val = e.target.value;
            if (!val) return;
            if (!isAction) {
              this.setState({ selected: val });
            }
            onSelected && onSelected(val);
          }}
        >
          {usesSentinel && <option value="" disabled hidden />}
          {options.map((opt) => (
            <option key={opt} value={opt}>
              {opt}
            </option>
          ))}
        </select>
      </Box>
    );
  }
}

```

`packages\tgui\components\Flex.tsx`

```tsx
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from "common/react";
import { BoxProps, computeBoxClassName, computeBoxProps, unit } from "./Box";

export type FlexProps = BoxProps & {
  direction?: string | BooleanLike;
  wrap?: string | BooleanLike;
  align?: string | BooleanLike;
  justify?: string | BooleanLike;
  inline?: BooleanLike;
};

export const computeFlexClassName = (props: FlexProps) => {
  return classes([
    "Flex",
    props.inline && "Flex--inline",
  ]);
};

export const computeFlexProps = (props: FlexProps) => {
  const { className, direction, wrap, align, justify, inline, ...rest } = props;
  return {
    style: {
      ...rest.style,
      "flex-direction": direction,
      "flex-wrap": wrap === true ? "wrap" : wrap,
      "align-items": align,
      "justify-content": justify,
    },
    ...rest,
  };
};

export const Flex = (props) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([
        className,
        computeFlexClassName(rest),
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(computeFlexProps(rest))}
    />
  );
};

Flex.defaultHooks = pureComponentHooks;

export type FlexItemProps = BoxProps & {
  grow?: number;
  order?: number;
  shrink?: number;
  basis?: string | BooleanLike;
  align?: string | BooleanLike;
};

export const computeFlexItemClassName = (props: FlexItemProps) => {
  return classes(["Flex__item"]);
};

export const computeFlexItemProps = (props: FlexItemProps) => {
  const {
    className,
    style,
    grow,
    order,
    shrink,
    // IE11: Always set basis to specified width, which fixes certain
    // bugs when rendering tables inside the flex.
    basis = props.width,
    align,
    ...rest
  } = props;
  return {
    style: {
      ...style,
      "flex-grow": grow !== undefined && Number(grow),
      "flex-shrink": shrink !== undefined && Number(shrink),
      "flex-basis": unit(basis),
      order: order,
      "align-self": align,
    },
    ...rest,
  };
};

const FlexItem = (props) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([
        className,
        computeFlexItemClassName(props),
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(computeFlexItemProps(rest))}
    />
  );
};

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;

```

`packages\tgui\components\GameIcon.tsx`

```tsx
interface GameIconProps {
  html: string;
  className?: string | null;
  style?: any | null;
  title?: string | null;
  key?: any;
}

export const GameIcon = (props: GameIconProps) => {
  const { html, className, style, key } = props;
  const iconSrc = html.match("src=[\"'](.*)[\"']")[1];

  return (
    <img
      key={key}
      {...props}
      className={`game-icon ${className || ""}`}
      src={iconSrc}
      style={{ "-ms-interpolation-mode": "nearest-neighbor", ...style }}
    />
  );
};

```

`packages\tgui\components\Grid.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Table } from "./Table";
import { pureComponentHooks } from "common/react";

/** @deprecated */
export const Grid = (props) => {
  const { children, ...rest } = props;
  return (
    <Table {...rest}>
      <Table.Row>{children}</Table.Row>
    </Table>
  );
};

Grid.defaultHooks = pureComponentHooks;

/** @deprecated */
export const GridColumn = (props) => {
  const { size = 1, style, ...rest } = props;
  return (
    <Table.Cell
      style={{
        width: size + "%",
        ...style,
      }}
      {...rest}
    />
  );
};

Grid.defaultHooks = pureComponentHooks;

Grid.Column = GridColumn;

```

`packages\tgui\components\Icon.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original Aleksej Komarov
 * @author Changes ThePotato97
 * @license MIT
 */

import { classes, pureComponentHooks } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = (props) => {
  const { name, size, spin, className, rotation, inverse, ...rest } = props;
  const boxProps = computeBoxProps(rest);
  if (size) {
    if (!boxProps.style) {
      boxProps.style = {};
    }
    boxProps.style["font-size"] = size * 100 + "%";
  }
  if (typeof rotation === "number") {
    if (!boxProps.style) {
      boxProps.style = {};
    }
    boxProps.style.transform = `rotate(${rotation}deg)`;
  }
  let iconClass = "";
  if (name.startsWith("tg-")) {
    // tgfont icon
    iconClass = name;
  } else {
    // font awesome icon
    const faRegular = FA_OUTLINE_REGEX.test(name);
    const faName = name.replace(FA_OUTLINE_REGEX, "");
    iconClass =
      (faRegular ? "far " : "fas ") + "fa-" + faName + (spin ? " fa-spin" : "");
  }
  return (
    <i
      className={classes([
        "Icon",
        iconClass,
        className,
        computeBoxClassName(rest),
      ])}
      {...boxProps}
    />
  );
};

Icon.defaultHooks = pureComponentHooks;

export const IconStack = (props) => {
  const { className, children, ...rest } = props;
  return (
    <span
      class={classes(["IconStack", className, computeBoxClassName(rest)])}
      {...computeBoxProps(rest)}
    >
      {children}
    </span>
  );
};

Icon.Stack = IconStack;

```

`packages\tgui\components\InfinitePlane.js`

```javascript
import { computeBoxProps } from "./Box";
import { Stack } from "./Stack";
import { ProgressBar } from "./ProgressBar";
import { Button } from "./Button";
import { Component } from "inferno";

const ZOOM_MIN_VAL = 0.5;
const ZOOM_MAX_VAL = 1.5;

const ZOOM_INCREMENT = 0.1;

export class InfinitePlane extends Component {
  constructor() {
    super();

    this.state = {
      mouseDown: false,

      left: 0,
      top: 0,

      lastLeft: 0,
      lastTop: 0,

      zoom: 1,
    };

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.onMouseUp = this.onMouseUp.bind(this);

    this.doOffsetMouse = this.doOffsetMouse.bind(this);
  }

  componentDidMount() {
    window.addEventListener("mouseup", this.onMouseUp);

    window.addEventListener("mousedown", this.doOffsetMouse);
    window.addEventListener("mousemove", this.doOffsetMouse);
    window.addEventListener("mouseup", this.doOffsetMouse);
  }

  componentWillUnmount() {
    window.removeEventListener("mouseup", this.onMouseUp);

    window.removeEventListener("mousedown", this.doOffsetMouse);
    window.removeEventListener("mousemove", this.doOffsetMouse);
    window.removeEventListener("mouseup", this.doOffsetMouse);
  }

  doOffsetMouse(event) {
    const { zoom } = this.state;
    event.screenZoomX = event.screenX * Math.pow(zoom, -1);
    event.screenZoomY = event.screenY * Math.pow(zoom, -1);
  }

  handleMouseDown(event) {
    this.setState((state) => {
      return {
        mouseDown: true,
        lastLeft: event.clientX - state.left,
        lastTop: event.clientY - state.top,
      };
    });
  }

  onMouseUp() {
    this.setState({
      mouseDown: false,
    });
  }

  handleMouseMove(event) {
    if (this.state.mouseDown) {
      this.setState((state) => {
        return {
          left: event.clientX - state.lastLeft,
          top: event.clientY - state.lastTop,
        };
      });
    }
  }

  render() {
    const { children, backgroundImage, imageWidth, ...rest } = this.props;
    const { left, top, zoom } = this.state;

    return (
      <div
        ref={this.ref}
        {...computeBoxProps({
          ...rest,
          style: {
            ...rest.style,
            overflow: "hidden",
            position: "relative",
          },
        })}
      >
        <div
          onMouseDown={this.handleMouseDown}
          onMouseMove={this.handleMouseMove}
          style={{
            position: "fixed",
            height: "100%",
            width: "100%",
            "background-image": `url("${backgroundImage}")`,
            "background-position": `${left}px ${top}px`,
            "background-repeat": "repeat",
            "background-size": `${zoom * imageWidth}px`,
          }}
        />
        <div
          onMouseDown={this.handleMouseDown}
          onMouseMove={this.handleMouseMove}
          style={{
            position: "fixed",
            transform: `translate(${left}px, ${top}px) scale(${zoom})`,
            "transform-origin": "top left",
            height: "100%",
            width: "100%",
          }}
        >
          {children}
        </div>

        <Stack position="absolute" width="100%">
          <Stack.Item>
            <Button
              icon="minus"
              onClick={() =>
                this.setState({
                  zoom: Math.max(zoom - ZOOM_INCREMENT, ZOOM_MIN_VAL),
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow={1}>
            <ProgressBar
              minValue={ZOOM_MIN_VAL}
              value={zoom}
              maxValue={ZOOM_MAX_VAL}
            >
              {zoom}x
            </ProgressBar>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() =>
                this.setState({
                  zoom: Math.min(zoom + ZOOM_INCREMENT, ZOOM_MAX_VAL),
                })
              }
            />
          </Stack.Item>
        </Stack>
      </div>
    );
  }
}

```

`packages\tgui\components\Input.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { Component, createRef } from "inferno";
import { Box } from "./Box";
import { KEY_ESCAPE, KEY_ENTER } from "common/keycodes";

export const toInputValue = (value) =>
  typeof value !== "number" && typeof value !== "string" ? "" : String(value);

export class Input extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
    this.handleInput = (e) => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, e.target.value);
      }
    };
    this.handleFocus = (e) => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = (e) => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };
    this.handleKeyDown = (e) => {
      const { onInput, onChange, onEnter } = this.props;
      if (e.keyCode === KEY_ENTER) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
        if (onInput) {
          onInput(e, e.target.value);
        }
        if (onEnter) {
          onEnter(e, e.target.value);
        }
        if (this.props.selfClear) {
          e.target.value = "";
        } else {
          e.target.blur();
        }
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        this.setEditing(false);
        e.target.value = toInputValue(this.props.value);
        e.target.blur();
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
    }
    if (this.props.autoFocus) {
      setTimeout(() => input.focus(), 1);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input && !editing && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    // Input only props
    const {
      selfClear,
      onInput,
      onChange,
      onEnter,
      value,
      maxLength,
      placeholder,
      ...boxProps
    } = props;
    // Box props
    const { className, fluid, monospace, ...rest } = boxProps;
    return (
      <Box
        className={classes([
          "Input",
          fluid && "Input--fluid",
          monospace && "Input--monospace",
          className,
        ])}
        {...rest}
      >
        <div className="Input__baseline">.</div>
        <input
          ref={this.inputRef}
          className="Input__input"
          placeholder={placeholder}
          onInput={this.handleInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          maxLength={maxLength}
        />
      </Box>
    );
  }
}

```

`packages\tgui\components\Interactive.tsx`

```tsx
/**
 * MIT License
 * https://github.com/omgovich/react-colorful/
 *
 * Copyright (c) 2020 Vlad Shilov <omgovich@ya.ru>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import { clamp } from "common/math";
import { Component, InfernoNode, createRef, RefObject } from "inferno";

export interface Interaction {
  left: number;
  top: number;
}

// Finds the proper window object to fix iframe embedding issues
const getParentWindow = (node?: HTMLDivElement | null): Window => {
  return (node && node.ownerDocument.defaultView) || self;
};

// Returns a relative position of the pointer inside the node's bounding box
const getRelativePosition = (
  node: HTMLDivElement,
  event: MouseEvent
): Interaction => {
  const rect = node.getBoundingClientRect();
  const pointer = event as MouseEvent;
  return {
    left: clamp(
      (pointer.pageX - (rect.left + getParentWindow(node).pageXOffset)) /
        rect.width,
      0,
      1
    ),
    top: clamp(
      (pointer.pageY - (rect.top + getParentWindow(node).pageYOffset)) /
        rect.height,
      0,
      1
    ),
  };
};

export interface InteractiveProps {
  onMove: (interaction: Interaction) => void;
  onKey: (offset: Interaction) => void;
  children: InfernoNode[];
  style?: any;
}

export class Interactive extends Component {
  containerRef: RefObject<HTMLDivElement>;
  props: InteractiveProps;

  constructor(props: InteractiveProps) {
    super();
    this.props = props;
    this.containerRef = createRef();
  }

  handleMoveStart = (event: MouseEvent) => {
    const el = this.containerRef?.current;
    if (!el) return;

    // Prevent text selection
    event.preventDefault();
    el.focus();
    this.props.onMove(getRelativePosition(el, event));
    this.toggleDocumentEvents(true);
  };

  handleMove = (event: MouseEvent) => {
    // Prevent text selection
    event.preventDefault();

    // If user moves the pointer outside of the window or iframe bounds and release it there,
    // `mouseup`/`touchend` won't be fired. In order to stop the picker from following the cursor
    // after the user has moved the mouse/finger back to the document, we check `event.buttons`
    // and `event.touches`. It allows us to detect that the user is just moving his pointer
    // without pressing it down
    const isDown = event.buttons > 0;

    if (isDown && this.containerRef?.current) {
      this.props.onMove(getRelativePosition(this.containerRef.current, event));
    } else {
      this.toggleDocumentEvents(false);
    }
  };

  handleMoveEnd = () => {
    this.toggleDocumentEvents(false);
  };

  handleKeyDown = (event: KeyboardEvent) => {
    const keyCode = event.which || event.keyCode;

    // Ignore all keys except arrow ones
    if (keyCode < 37 || keyCode > 40) return;
    // Do not scroll page by arrow keys when document is focused on the element
    event.preventDefault();
    // Send relative offset to the parent component.
    // We use codes (37←, 38↑, 39→, 40↓) instead of keys ('ArrowRight', 'ArrowDown', etc)
    // to reduce the size of the library
    this.props.onKey({
      left: keyCode === 39 ? 0.05 : keyCode === 37 ? -0.05 : 0,
      top: keyCode === 40 ? 0.05 : keyCode === 38 ? -0.05 : 0,
    });
  };

  toggleDocumentEvents(state?: boolean) {
    const el = this.containerRef?.current;
    const parentWindow = getParentWindow(el);

    // Add or remove additional pointer event listeners
    const toggleEvent = state
      ? parentWindow.addEventListener
      : parentWindow.removeEventListener;
    toggleEvent("mousemove", this.handleMove);
    toggleEvent("mouseup", this.handleMoveEnd);
  }

  componentDidMount() {
    this.toggleDocumentEvents(true);
  }

  componentWillUnmount() {
    this.toggleDocumentEvents(false);
  }

  render() {
    return (
      <div
        {...this.props}
        style={this.props.style}
        ref={this.containerRef}
        onMouseDown={this.handleMoveStart}
        className="react-colorful__interactive"
        onKeyDown={this.handleKeyDown}
        tabIndex={0}
        role="slider"
      >
        {this.props.children}
      </div>
    );
  }
}

```

`packages\tgui\components\Knob.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { keyOfMatchingRange, scale } from "common/math";
import { classes } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";
import { DraggableControl } from "./DraggableControl";
import { NumberInput } from "./NumberInput";

export const Knob = (props) => {
  const {
    // Draggable props (passthrough)
    animated,
    format,
    maxValue,
    minValue,
    unclamped,
    onChange,
    onDrag,
    step,
    stepPixelSize,
    suppressFlicker,
    unit,
    value,
    // Own props
    className,
    style,
    fillValue,
    color,
    ranges = {},
    size = 1,
    bipolar,
    children,
    ...rest
  } = props;
  return (
    <DraggableControl
      dragMatrix={[0, -1]}
      {...{
        animated,
        format,
        maxValue,
        minValue,
        unclamped,
        onChange,
        onDrag,
        step,
        stepPixelSize,
        suppressFlicker,
        unit,
        value,
      }}
    >
      {(control) => {
        const {
          dragging,
          value,
          displayValue,
          displayElement,
          inputElement,
          handleDragStart,
        } = control;
        const scaledFillValue = scale(
          fillValue ?? displayValue,
          minValue,
          maxValue,
        );
        const scaledDisplayValue = scale(displayValue, minValue, maxValue);
        const effectiveColor =
          color || keyOfMatchingRange(fillValue ?? value, ranges) || "default";
        const rotation = Math.min((scaledDisplayValue - 0.5) * 270, 225);
        return (
          <div
            className={classes([
              "Knob",
              "Knob--color--" + effectiveColor,
              bipolar && "Knob--bipolar",
              className,
              computeBoxClassName(rest),
            ])}
            {...computeBoxProps({
              style: {
                "font-size": size + "em",
                ...style,
              },
              ...rest,
            })}
            onMouseDown={handleDragStart}
          >
            <div className="Knob__circle">
              <div
                className="Knob__cursorBox"
                style={{
                  transform: `rotate(${rotation}deg)`,
                }}
              >
                <div className="Knob__cursor" />
              </div>
            </div>
            {dragging && (
              <div className="Knob__popupValue">{displayElement}</div>
            )}
            <svg
              className="Knob__ring Knob__ringTrackPivot"
              viewBox="0 0 100 100"
            >
              <circle className="Knob__ringTrack" cx="50" cy="50" r="50" />
            </svg>
            <svg
              className="Knob__ring Knob__ringFillPivot"
              viewBox="0 0 100 100"
            >
              <circle
                className="Knob__ringFill"
                style={{
                  "stroke-dashoffset": Math.max(
                    ((bipolar ? 2.75 : 2.0) - scaledFillValue * 1.5) *
                      Math.PI *
                      50,
                    0,
                  ),
                }}
                cx="50"
                cy="50"
                r="50"
              />
            </svg>
            {inputElement}
          </div>
        );
      }}
    </DraggableControl>
  );
};

```

`packages\tgui\components\LabeledControls.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Flex } from "./Flex";

export const LabeledControls = (props) => {
  const { children, wrap, ...rest } = props;
  return (
    <Flex
      mx={-0.5}
      wrap={wrap}
      align="stretch"
      justify="space-between"
      {...rest}
    >
      {children}
    </Flex>
  );
};

const LabeledControlsItem = (props) => {
  const { label, children, mx = 1, ...rest } = props;
  return (
    <Flex.Item mx={mx}>
      <Flex
        height="100%"
        direction="column"
        align="center"
        textAlign="center"
        justify="space-between"
        {...rest}
      >
        <Flex.Item />
        <Flex.Item>{children}</Flex.Item>
        <Flex.Item color="label">{label}</Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

LabeledControls.Item = LabeledControlsItem;

```

`packages\tgui\components\LabeledList.tsx`

```tsx
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from "common/react";
import { InfernoNode } from "inferno";
import { Box, unit } from "./Box";
import { Divider } from "./Divider";

type LabeledListProps = {
  children?: any;
};

export const LabeledList = (props: LabeledListProps) => {
  const { children } = props;
  return <table className="LabeledList">{children}</table>;
};

LabeledList.defaultHooks = pureComponentHooks;

type LabeledListItemProps = {
  className?: string | BooleanLike;
  label?: string | BooleanLike;
  labelColor?: string | BooleanLike;
  color?: string | BooleanLike;
  textAlign?: string | BooleanLike;
  buttons?: InfernoNode;
  /** @deprecated */
  content?: any;
  children?: InfernoNode;
};

const LabeledListItem = (props: LabeledListItemProps) => {
  const {
    className,
    label,
    labelColor = "label",
    color,
    textAlign,
    buttons,
    content,
    children,
  } = props;
  return (
    <tr className={classes(["LabeledList__row", className])}>
      <Box
        as="td"
        color={labelColor}
        className={classes(["LabeledList__cell", "LabeledList__label"])}
      >
        {label ? label + ":" : null}
      </Box>
      <Box
        as="td"
        color={color}
        textAlign={textAlign}
        className={classes(["LabeledList__cell", "LabeledList__content"])}
        colSpan={buttons ? undefined : 2}
      >
        {content}
        {children}
      </Box>
      {buttons && (
        <td className="LabeledList__cell LabeledList__buttons">{buttons}</td>
      )}
    </tr>
  );
};

LabeledListItem.defaultHooks = pureComponentHooks;

type LabeledListDividerProps = {
  size?: number;
};

const LabeledListDivider = (props: LabeledListDividerProps) => {
  const padding = props.size ? unit(Math.max(0, props.size - 1)) : 0;
  return (
    <tr className="LabeledList__row">
      <td
        colSpan={3}
        style={{
          "padding-top": padding,
          "padding-bottom": padding,
        }}
      >
        <Divider />
      </td>
    </tr>
  );
};

LabeledListDivider.defaultHooks = pureComponentHooks;

LabeledList.Item = LabeledListItem;
LabeledList.Divider = LabeledListDivider;

```

`packages\tgui\components\Modal.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";
import { Dimmer } from "./Dimmer";

export const Modal = (props) => {
  const { className, children, ...rest } = props;
  return (
    <Dimmer>
      <div
        className={classes(["Modal", className, computeBoxClassName(rest)])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    </Dimmer>
  );
};

```

`packages\tgui\components\NoticeBox.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from "common/react";
import { Box } from "./Box";

export const NoticeBox = (props) => {
  const { className, color, info, warning, success, danger, ...rest } = props;
  return (
    <Box
      className={classes([
        "NoticeBox",
        color && "NoticeBox--color--" + color,
        info && "NoticeBox--type--info",
        success && "NoticeBox--type--success",
        danger && "NoticeBox--type--danger",
        className,
      ])}
      {...rest}
    />
  );
};

NoticeBox.defaultHooks = pureComponentHooks;

```

`packages\tgui\components\NumberInput.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp } from "common/math";
import { classes, pureComponentHooks } from "common/react";
import { Component, createRef } from "inferno";
import { AnimatedNumber } from "./AnimatedNumber";
import { Box } from "./Box";

const DEFAULT_UPDATE_RATE = 400;

export class NumberInput extends Component {
  constructor(props) {
    super(props);
    const { value } = props;
    this.inputRef = createRef();
    this.state = {
      value,
      dragging: false,
      editing: false,
      internalValue: null,
      origin: null,
      suppressingFlicker: false,
    };

    // Suppresses flickering while the value propagates through the backend
    this.flickerTimer = null;
    this.suppressFlicker = () => {
      const { suppressFlicker } = this.props;
      if (suppressFlicker > 0) {
        this.setState({
          suppressingFlicker: true,
        });
        clearTimeout(this.flickerTimer);
        this.flickerTimer = setTimeout(
          () =>
            this.setState({
              suppressingFlicker: false,
            }),
          suppressFlicker,
        );
      }
    };

    this.handleDragStart = (e) => {
      const { value } = this.props;
      const { editing } = this.state;
      if (editing) {
        return;
      }
      document.body.style["pointer-events"] = "none";
      this.ref = e.target;
      this.setState({
        dragging: false,
        origin: e.screenY,
        value,
        internalValue: value,
      });
      this.timer = setTimeout(() => {
        this.setState({
          dragging: true,
        });
      }, 250);
      this.dragInterval = setInterval(() => {
        const { dragging, value } = this.state;
        const { onDrag } = this.props;
        if (dragging && onDrag) {
          onDrag(e, value);
        }
      }, this.props.updateRate || DEFAULT_UPDATE_RATE);
      document.addEventListener("mousemove", this.handleDragMove);
      document.addEventListener("mouseup", this.handleDragEnd);
    };

    this.handleDragMove = (e) => {
      const { minValue, maxValue, step, stepPixelSize } = this.props;
      this.setState((prevState) => {
        const state = { ...prevState };
        const offset = state.origin - e.screenY;
        if (prevState.dragging) {
          const stepOffset = Number.isFinite(minValue) ? minValue % step : 0;
          // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)
          state.internalValue = clamp(
            state.internalValue + (offset * step) / stepPixelSize,
            minValue - step,
            maxValue + step,
          );
          // Clamp the final value
          state.value = clamp(
            state.internalValue - (state.internalValue % step) + stepOffset,
            minValue,
            maxValue,
          );
          state.origin = e.screenY;
        } else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = (e) => {
      const { onChange, onDrag } = this.props;
      const { dragging, value, internalValue } = this.state;
      document.body.style["pointer-events"] = "auto";
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      this.setState({
        dragging: false,
        editing: !dragging,
        origin: null,
      });
      document.removeEventListener("mousemove", this.handleDragMove);
      document.removeEventListener("mouseup", this.handleDragEnd);
      if (dragging) {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, value);
        }
        if (onDrag) {
          onDrag(e, value);
        }
      } else if (this.inputRef) {
        const input = this.inputRef.current;
        input.value = internalValue;
        // IE8: Dies when trying to focus a hidden element
        // (Error: Object does not support this action)
        try {
          input.focus();
          input.select();
        } catch {}
      }
    };
  }

  render() {
    const {
      dragging,
      editing,
      value: intermediateValue,
      suppressingFlicker,
    } = this.state;
    const {
      className,
      fluid,
      animated,
      value,
      unit,
      minValue,
      maxValue,
      height,
      width,
      lineHeight,
      fontSize,
      format,
      onChange,
      onDrag,
    } = this.props;
    let displayValue = value;
    if (dragging || suppressingFlicker) {
      displayValue = intermediateValue;
    }
    const renderContentElement = (value) => (
      <div className="NumberInput__content">
        {value + (unit ? " " + unit : "")}
      </div>
    );
    const contentElement =
      (animated && !dragging && !suppressingFlicker && (
        <AnimatedNumber value={displayValue} format={format}>
          {renderContentElement}
        </AnimatedNumber>
      )) ||
      renderContentElement(format ? format(displayValue) : displayValue);
    return (
      <Box
        className={classes([
          "NumberInput",
          fluid && "NumberInput--fluid",
          className,
        ])}
        minWidth={width}
        minHeight={height}
        lineHeight={lineHeight}
        fontSize={fontSize}
        onMouseDown={this.handleDragStart}
      >
        <div className="NumberInput__barContainer">
          <div
            className="NumberInput__bar"
            style={{
              height:
                clamp(
                  ((displayValue - minValue) / (maxValue - minValue)) * 100,
                  0,
                  100,
                ) + "%",
            }}
          />
        </div>
        {contentElement}
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            display: !editing ? "none" : undefined,
            height: height,
            "line-height": lineHeight,
            "font-size": fontSize,
          }}
          onBlur={(e) => {
            if (!editing) {
              return;
            }
            const value = clamp(parseFloat(e.target.value), minValue, maxValue);
            if (Number.isNaN(value)) {
              this.setState({
                editing: false,
              });
              return;
            }
            this.setState({
              editing: false,
              value,
            });
            this.suppressFlicker();
            if (onChange) {
              onChange(e, value);
            }
            if (onDrag) {
              onDrag(e, value);
            }
          }}
          onKeyDown={(e) => {
            if (e.keyCode === 13) {
              const value = clamp(
                parseFloat(e.target.value),
                minValue,
                maxValue,
              );
              if (Number.isNaN(value)) {
                this.setState({
                  editing: false,
                });
                return;
              }
              this.setState({
                editing: false,
                value,
              });
              this.suppressFlicker();
              if (onChange) {
                onChange(e, value);
              }
              if (onDrag) {
                onDrag(e, value);
              }
              return;
            }
            if (e.keyCode === 27) {
              this.setState({
                editing: false,
              });
            }
          }}
        />
      </Box>
    );
  }
}

NumberInput.defaultHooks = pureComponentHooks;
NumberInput.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  stepPixelSize: 1,
  suppressFlicker: 50,
};

```

`packages\tgui\components\Pointer.tsx`

```tsx
/**
 * MIT License
 * https://github.com/omgovich/react-colorful/
 *
 * Copyright (c) 2020 Vlad Shilov <omgovich@ya.ru>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import { classes } from "common/react";
import { InfernoNode } from "inferno";

interface PointerProps {
  className?: string;
  top?: number;
  left: number;
  color: string;
}

export const Pointer = ({
  className,
  color,
  left,
  top = 0.5,
}: PointerProps): InfernoNode => {
  const nodeClassName = classes(["react-colorful__pointer", className]);

  const style = {
    top: `${top * 100}%`,
    left: `${left * 100}%`,
  };

  return (
    <div className={nodeClassName} style={style}>
      <div
        className="react-colorful__pointer-fill"
        style={{ "background-color": color }}
      />
    </div>
  );
};

```

`packages\tgui\components\Popper.tsx`

```tsx
import { createPopper } from "@popperjs/core";
import { ArgumentsOf } from "common/types.js";
import { Component, findDOMFromVNode, InfernoNode, render } from "inferno";

type PopperProps = {
  popperContent: InfernoNode;
  options?: ArgumentsOf<typeof createPopper>[2];
  additionalStyles?: CSSProperties;
};

export class Popper extends Component<PopperProps> {
  static id: number = 0;

  renderedContent: HTMLDivElement;
  popperInstance: ReturnType<typeof createPopper>;

  constructor() {
    super();

    Popper.id += 1;
  }

  componentDidMount() {
    const { additionalStyles, options } = this.props;

    this.renderedContent = document.createElement("div");

    if (additionalStyles) {
      for (const [attribute, value] of Object.entries(additionalStyles)) {
        this.renderedContent.style[attribute] = value;
      }
    }

    this.renderPopperContent(() => {
      document.body.appendChild(this.renderedContent);

      // HACK: We don't want to create a wrapper, as it could break the layout
      // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
      // This is usually bad as refs are usually better, but refs did
      // not work in this case, as they weren't propagating correctly.
      // A previous attempt was made as a render prop that passed an ID,
      // but this made consuming use too unwieldly.
      // This code is copied from `findDOMNode` in inferno-extras.
      // Because this component is written in TypeScript, we will know
      // immediately if this internal variable is removed.
      const domNode = findDOMFromVNode(this.$LI, true);
      if (!domNode) {
        return;
      }

      this.popperInstance = createPopper(
        domNode,
        this.renderedContent,
        options
      );
    });
  }

  componentDidUpdate() {
    this.renderPopperContent(() => this.popperInstance?.update());
  }

  componentWillUnmount() {
    this.popperInstance?.destroy();
    render(null, this.renderedContent, () => {
      this.renderedContent.remove();
    });
  }

  renderPopperContent(callback: () => void) {
    // `render` errors when given false, so we convert it to `null`,
    // which is supported.
    render(
      this.props.popperContent || null,
      this.renderedContent,
      callback,
      this.context
    );
  }

  render() {
    return this.props.children;
  }
}

```

`packages\tgui\components\ProgressBar.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp01, scale, keyOfMatchingRange, toFixed } from "common/math";
import { classes, pureComponentHooks } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";

export const ProgressBar = (props) => {
  const {
    className,
    value,
    minValue = 0,
    maxValue = 1,
    color,
    ranges = {},
    children,
    ...rest
  } = props;
  const scaledValue = scale(value, minValue, maxValue);
  const hasContent = children !== undefined;
  const effectiveColor =
    color || keyOfMatchingRange(value, ranges) || "default";
  return (
    <div
      className={classes([
        "ProgressBar",
        "ProgressBar--color--" + effectiveColor,
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={{
          width: clamp01(scaledValue) * 100 + "%",
        }}
      />
      <div className="ProgressBar__content">
        {hasContent ? children : toFixed(scaledValue * 100) + "%"}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;

```

`packages\tgui\components\RestrictedInput.js`

```javascript
import { classes } from 'common/react';
import { clamp } from 'common/math';
import { Component, createRef } from 'inferno';
import { Box } from './Box';
import { KEY_ESCAPE, KEY_ENTER } from 'common/keycodes';

const DEFAULT_MIN = 0;
const DEFAULT_MAX = 10000;

/**
 * Takes a string input and parses integers or floats from it.
 * If none: Minimum is set.
 * Else: Clamps it to the given range.
 */
const getClampedNumber = (value, minValue, maxValue, allowFloats) => {
  const minimum = minValue || DEFAULT_MIN;
  const maximum = maxValue || maxValue === 0 ? maxValue : DEFAULT_MAX;
  if (!value || !value.length) {
    return String(minimum);
  }
  let parsedValue = allowFloats
    ? parseFloat(value.replace(/[^\-\d.]/g, ''))
    : parseInt(value.replace(/[^\-\d]/g, ''), 10);
  if (isNaN(parsedValue)) {
    return String(minimum);
  } else {
    return String(clamp(parsedValue, minimum, maximum));
  }
};

export class RestrictedInput extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
    this.handleBlur = (e) => {
      const { editing } = this.state;
      if (editing) {
        this.setEditing(false);
      }
    };
    this.handleChange = (e) => {
      const { maxValue, minValue, onChange, allowFloats } = this.props;
      e.target.value = getClampedNumber(
        e.target.value,
        minValue,
        maxValue,
        allowFloats
      );
      if (onChange) {
        onChange(e, +e.target.value);
      }
    };
    this.handleFocus = (e) => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleInput = (e) => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, +e.target.value);
      }
    };
    this.handleKeyDown = (e) => {
      const { maxValue, minValue, onChange, onEnter, allowFloats } = this.props;
      if (e.keyCode === KEY_ENTER) {
        const safeNum = getClampedNumber(
          e.target.value,
          minValue,
          maxValue,
          allowFloats
        );
        this.setEditing(false);
        if (onChange) {
          onChange(e, +safeNum);
        }
        if (onEnter) {
          onEnter(e, +safeNum);
        }
        e.target.blur();
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        if (this.props.onEscape) {
          this.props.onEscape(e);
          return;
        }
        this.setEditing(false);
        e.target.value = this.props.value;
        e.target.blur();
        return;
      }
    };
  }

  componentDidMount() {
    const { maxValue, minValue, allowFloats } = this.props;
    const nextValue = this.props.value?.toString();
    const input = this.inputRef.current;
    if (input) {
      input.value = getClampedNumber(
        nextValue,
        minValue,
        maxValue,
        allowFloats
      );
    }
    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        input.focus();

        if (this.props.autoSelect) {
          input.select();
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps, _) {
    const { maxValue, minValue, allowFloats } = this.props;
    const { editing } = this.state;
    const prevValue = prevProps.value?.toString();
    const nextValue = this.props.value?.toString();
    const input = this.inputRef.current;
    if (input && !editing) {
      if (nextValue !== prevValue && nextValue !== input.value) {
        input.value = getClampedNumber(
          nextValue,
          minValue,
          maxValue,
          allowFloats
        );
      }
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    const { onChange, onEnter, onInput, value, ...boxProps } = props;
    const { className, fluid, monospace, ...rest } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          className,
        ])}
        {...rest}>
        <div className="Input__baseline">.</div>
        <input
          className="Input__input"
          onChange={this.handleChange}
          onInput={this.handleInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          ref={this.inputRef}
          type="number"
        />
      </Box>
    );
  }
}

```

`packages\tgui\components\RoundGauge.js`

```javascript
/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { clamp01, keyOfMatchingRange, scale } from "common/math";
import { classes } from "common/react";
import { AnimatedNumber } from "./AnimatedNumber";
import { Box, computeBoxClassName, computeBoxProps } from "./Box";

export const RoundGauge = (props) => {
  const {
    value,
    minValue = 1,
    maxValue = 1,
    ranges,
    alertAfter,
    format,
    size = 1,
    className,
    style,
    ...rest
  } = props;

  const scaledValue = scale(value, minValue, maxValue);
  const clampedValue = clamp01(scaledValue);
  const scaledRanges = ranges ? {} : { primary: [0, 1] };
  if (ranges) {
    Object.keys(ranges).forEach((x) => {
      const range = ranges[x];
      scaledRanges[x] = [
        scale(range[0], minValue, maxValue),
        scale(range[1], minValue, maxValue),
      ];
    });
  }

  let alertColor = null;
  if (alertAfter < value) {
    alertColor = keyOfMatchingRange(clampedValue, scaledRanges);
  }

  return (
    <Box inline>
      <div
        className={classes([
          "RoundGauge",
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps({
          style: {
            "font-size": size + "em",
            ...style,
          },
          ...rest,
        })}
      >
        <svg viewBox="0 0 100 50">
          {alertAfter && (
            <g
              className={classes([
                "RoundGauge__alert",
                alertColor ? `active RoundGauge__alert--${alertColor}` : "",
              ])}
            >
              <path d="M48.211,14.578C48.55,13.9 49.242,13.472 50,13.472C50.758,13.472 51.45,13.9 51.789,14.578C54.793,20.587 60.795,32.589 63.553,38.106C63.863,38.726 63.83,39.462 63.465,40.051C63.101,40.641 62.457,41 61.764,41C55.996,41 44.004,41 38.236,41C37.543,41 36.899,40.641 36.535,40.051C36.17,39.462 36.137,38.726 36.447,38.106C39.205,32.589 45.207,20.587 48.211,14.578ZM50,34.417C51.426,34.417 52.583,35.574 52.583,37C52.583,38.426 51.426,39.583 50,39.583C48.574,39.583 47.417,38.426 47.417,37C47.417,35.574 48.574,34.417 50,34.417ZM50,32.75C50,32.75 53,31.805 53,22.25C53,20.594 51.656,19.25 50,19.25C48.344,19.25 47,20.594 47,22.25C47,31.805 50,32.75 50,32.75Z" />
            </g>
          )}
          <g>
            <circle className="RoundGauge__ringTrack" cx="50" cy="50" r="45" />
          </g>
          <g>
            {Object.keys(scaledRanges).map((x, i) => {
              const colRanges = scaledRanges[x];
              return (
                <circle
                  className={`RoundGauge__ringFill RoundGauge--color--${x}`}
                  key={i}
                  style={{
                    "stroke-dashoffset": Math.max(
                      (2.0 - (colRanges[1] - colRanges[0])) * Math.PI * 50,
                      0,
                    ),
                  }}
                  transform={`rotate(${180 + 180 * colRanges[0]} 50 50)`}
                  cx="50"
                  cy="50"
                  r="45"
                />
              );
            })}
          </g>
          <g
            className="RoundGauge__needle"
            transform={`rotate(${clampedValue * 180 - 90} 50 50)`}
          >
            <polygon
              className="RoundGauge__needleLine"
              points="46,50 50,0 54,50"
            />
            <circle
              className="RoundGauge__needleMiddle"
              cx="50"
              cy="50"
              r="8"
            />
          </g>
        </svg>
      </div>
      <AnimatedNumber value={value} format={format} size={size} />
    </Box>
  );
};

```

`packages\tgui\components\Section.tsx`

```tsx
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from "common/react";
import { Component, createRef, InfernoNode, RefObject } from "inferno";
import { addScrollableNode, removeScrollableNode } from "../events";
import { BoxProps, computeBoxClassName, computeBoxProps } from "./Box";

interface SectionProps extends BoxProps {
  className?: string;
  title?: string;
  buttons?: InfernoNode;
  fill?: boolean;
  fitted?: boolean;
  scrollable?: boolean;
  /** @deprecated This property no longer works, please remove it. */
  level?: boolean;
  /** @deprecated Please use `scrollable` property */
  overflowY?: any;
}

export class Section extends Component<SectionProps> {
  scrollableRef: RefObject<HTMLDivElement>;
  scrollable: boolean;

  constructor(props) {
    super(props);
    this.scrollableRef = createRef();
    this.scrollable = props.scrollable;
  }

  componentDidMount() {
    if (this.scrollable) {
      addScrollableNode(this.scrollableRef.current);
    }
  }

  componentWillUnmount() {
    if (this.scrollable) {
      removeScrollableNode(this.scrollableRef.current);
    }
  }

  render() {
    const {
      className,
      title,
      buttons,
      fill,
      fitted,
      scrollable,
      children,
      ...rest
    } = this.props;
    const hasTitle = canRender(title) || canRender(buttons);
    return (
      <div
        className={classes([
          "Section",
          fill && "Section--fill",
          fitted && "Section--fitted",
          scrollable && "Section--scrollable",
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}
      >
        {hasTitle && (
          <div className="Section__title">
            <span className="Section__titleText">{title}</span>
            <div className="Section__buttons">{buttons}</div>
          </div>
        )}
        <div className="Section__rest">
          <div ref={this.scrollableRef} className="Section__content">
            {children}
          </div>
        </div>
      </div>
    );
  }
}

```

`packages\tgui\components\Slider.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp01, keyOfMatchingRange, scale } from "common/math";
import { classes } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";
import { DraggableControl } from "./DraggableControl";
import { NumberInput } from "./NumberInput";

export const Slider = (props) => {
  const {
    // Draggable props (passthrough)
    animated,
    format,
    maxValue,
    minValue,
    onChange,
    onDrag,
    step,
    stepPixelSize,
    suppressFlicker,
    unit,
    value,
    // Own props
    className,
    fillValue,
    color,
    ranges = {},
    children,
    ...rest
  } = props;
  const hasContent = children !== undefined;
  return (
    <DraggableControl
      dragMatrix={[1, 0]}
      {...{
        animated,
        format,
        maxValue,
        minValue,
        onChange,
        onDrag,
        step,
        stepPixelSize,
        suppressFlicker,
        unit,
        value,
      }}
    >
      {(control) => {
        const {
          dragging,
          value,
          displayValue,
          displayElement,
          inputElement,
          handleDragStart,
        } = control;
        const hasFillValue = fillValue !== undefined && fillValue !== null;
        const scaledFillValue = scale(
          fillValue ?? displayValue,
          minValue,
          maxValue,
        );
        const scaledDisplayValue = scale(displayValue, minValue, maxValue);
        const effectiveColor =
          color || keyOfMatchingRange(fillValue ?? value, ranges) || "default";
        return (
          <div
            className={classes([
              "Slider",
              "ProgressBar",
              "ProgressBar--color--" + effectiveColor,
              className,
              computeBoxClassName(rest),
            ])}
            {...computeBoxProps(rest)}
            onMouseDown={handleDragStart}
          >
            <div
              className={classes([
                "ProgressBar__fill",
                hasFillValue && "ProgressBar__fill--animated",
              ])}
              style={{
                width: clamp01(scaledFillValue) * 100 + "%",
                opacity: 0.4,
              }}
            />
            <div
              className="ProgressBar__fill"
              style={{
                width:
                  clamp01(Math.min(scaledFillValue, scaledDisplayValue)) * 100 +
                  "%",
              }}
            />
            <div
              className="Slider__cursorOffset"
              style={{
                width: clamp01(scaledDisplayValue) * 100 + "%",
              }}
            >
              <div className="Slider__cursor" />
              <div className="Slider__pointer" />
              {dragging && (
                <div className="Slider__popupValue">{displayElement}</div>
              )}
            </div>
            <div className="ProgressBar__content">
              {hasContent ? children : displayElement}
            </div>
            {inputElement}
          </div>
        );
      }}
    </DraggableControl>
  );
};

```

`packages\tgui\components\Stack.tsx`

```tsx
/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";
import {
  computeFlexClassName,
  computeFlexItemClassName,
  computeFlexItemProps,
  computeFlexProps,
  FlexItemProps,
  FlexProps,
} from "./Flex";

type StackProps = FlexProps & {
  vertical?: boolean;
  fill?: boolean;
};

export const Stack = (props: StackProps) => {
  const { className, vertical, fill, ...rest } = props;
  return (
    <div
      className={classes([
        "Stack",
        fill && "Stack--fill",
        vertical ? "Stack--vertical" : "Stack--horizontal",
        className,
        computeFlexClassName(props),
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(
        computeFlexProps({
          direction: vertical ? "column" : "row",
          ...rest,
        })
      )}
    />
  );
};

const StackItem = (props: FlexProps) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([
        "Stack__item",
        className,
        computeFlexItemClassName(rest),
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(computeFlexItemProps(rest))}
    />
  );
};

Stack.Item = StackItem;

type StackDividerProps = FlexItemProps & {
  hidden?: boolean;
};

const StackDivider = (props: StackDividerProps) => {
  const { className, hidden, ...rest } = props;
  return (
    <div
      className={classes([
        "Stack__item",
        "Stack__divider",
        hidden && "Stack__divider--hidden",
        className,
        computeFlexItemClassName(rest),
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(computeFlexItemProps(rest))}
    />
  );
};

Stack.Divider = StackDivider;

```

`packages\tgui\components\Table.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";

export const Table = (props) => {
  const { className, collapsing, children, ...rest } = props;
  return (
    <table
      className={classes([
        "Table",
        collapsing && "Table--collapsing",
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <tbody>{children}</tbody>
    </table>
  );
};

Table.defaultHooks = pureComponentHooks;

export const TableRow = (props) => {
  const { className, header, ...rest } = props;
  return (
    <tr
      className={classes([
        "Table__row",
        header && "Table__row--header",
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
};

TableRow.defaultHooks = pureComponentHooks;

export const TableCell = (props) => {
  const { className, collapsing, header, ...rest } = props;
  return (
    <td
      className={classes([
        "Table__cell",
        collapsing && "Table__cell--collapsing",
        header && "Table__cell--header",
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
};

TableCell.defaultHooks = pureComponentHooks;

Table.Row = TableRow;
Table.Cell = TableCell;

```

`packages\tgui\components\Tabs.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from "common/react";
import { computeBoxClassName, computeBoxProps } from "./Box";
import { Icon } from "./Icon";

export const Tabs = (props) => {
  const { className, vertical, fill, fluid, children, ...rest } = props;
  return (
    <div
      className={classes([
        "Tabs",
        vertical ? "Tabs--vertical" : "Tabs--horizontal",
        fill && "Tabs--fill",
        fluid && "Tabs--fluid",
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      {children}
    </div>
  );
};

const Tab = (props) => {
  const {
    className,
    selected,
    color,
    icon,
    leftSlot,
    rightSlot,
    children,
    ...rest
  } = props;
  return (
    <div
      className={classes([
        "Tab",
        "Tabs__Tab",
        "Tab--color--" + color,
        selected && "Tab--selected",
        className,
        ...computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      {(canRender(leftSlot) && <div className="Tab__left">{leftSlot}</div>) ||
        (!!icon && (
          <div className="Tab__left">
            <Icon name={icon} />
          </div>
        ))}
      <div className="Tab__text">{children}</div>
      {canRender(rightSlot) && <div className="Tab__right">{rightSlot}</div>}
    </div>
  );
};

Tabs.Tab = Tab;

```

`packages\tgui\components\TextArea.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { classes } from "common/react";
import { Component, createRef } from "inferno";
import { Box } from "./Box";
import { toInputValue } from "./Input";
import { KEY_ESCAPE } from "common/keycodes";

export class TextArea extends Component {
  constructor(props, context) {
    super(props, context);
    this.textareaRef = createRef();
    this.fillerRef = createRef();
    this.state = {
      editing: false,
    };
    const { dontUseTabForIndent = false } = props;
    this.handleOnInput = (e) => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, e.target.value);
      }
    };
    this.handleOnChange = (e) => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
      }
      if (onChange) {
        onChange(e, e.target.value);
      }
    };
    this.handleKeyPress = (e) => {
      const { editing } = this.state;
      const { onKeyPress } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onKeyPress) {
        onKeyPress(e, e.target.value);
      }
    };
    this.handleKeyDown = (e) => {
      const { editing } = this.state;
      const { onKeyDown } = this.props;
      if (e.keyCode === KEY_ESCAPE) {
        this.setEditing(false);
        e.target.value = toInputValue(this.props.value);
        e.target.blur();
        return;
      }
      if (!editing) {
        this.setEditing(true);
      }
      if (!dontUseTabForIndent) {
        const keyCode = e.keyCode || e.which;
        if (keyCode === 9) {
          e.preventDefault();
          const { value, selectionStart, selectionEnd } = e.target;
          e.target.value =
            value.substring(0, selectionStart) +
            "\t" +
            value.substring(selectionEnd);
          e.target.selectionEnd = selectionStart + 1;
        }
      }
      if (onKeyDown) {
        onKeyDown(e, e.target.value);
      }
    };
    this.handleFocus = (e) => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = (e) => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input && !editing && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  getValue() {
    return this.textareaRef.current && this.textareaRef.current.value;
  }

  render() {
    // Input only props
    const {
      onChange,
      onKeyDown,
      onKeyPress,
      onInput,
      onFocus,
      onBlur,
      onEnter,
      value,
      maxLength,
      placeholder,
      ...boxProps
    } = this.props;
    // Box props
    const { className, fluid, ...rest } = boxProps;
    return (
      <Box
        className={classes(["TextArea", fluid && "TextArea--fluid", className])}
        {...rest}
      >
        <textarea
          ref={this.textareaRef}
          className="TextArea__textarea"
          placeholder={placeholder}
          onChange={this.handleOnChange}
          onKeyDown={this.handleKeyDown}
          onKeyPress={this.handleKeyPress}
          onInput={this.handleOnInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          maxLength={maxLength}
        />
      </Box>
    );
  }
}

```

`packages\tgui\components\TimeDisplay.js`

```javascript
import { formatTime } from "../format";
import { Component } from "inferno";

// AnimatedNumber Copypaste
const isSafeNumber = (value) => {
  return (
    typeof value === "number" && Number.isFinite(value) && !Number.isNaN(value)
  );
};

export class TimeDisplay extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.last_seen_value = undefined;
    this.state = {
      value: 0,
    };
    // Set initial state with value provided in props
    if (isSafeNumber(props.value)) {
      this.state.value = Number(props.value);
      this.last_seen_value = Number(props.value);
    }
  }

  componentDidUpdate() {
    if (this.props.auto !== undefined) {
      clearInterval(this.timer);
      this.timer = setInterval(() => this.tick(), 1000); // every 1 s
    }
  }

  tick() {
    let current = Number(this.state.value);
    if (this.props.value !== this.last_seen_value) {
      this.last_seen_value = this.props.value;
      current = this.props.value;
    }
    const mod = this.props.auto === "up" ? 10 : -10; // Time down by default.
    const value = Math.max(0, current + mod); // one sec tick
    this.setState({ value });
  }

  componentDidMount() {
    if (this.props.auto !== undefined) {
      this.timer = setInterval(() => this.tick(), 1000); // every 1 s
    }
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    const val = this.state.value;
    // Directly display weird stuff
    if (!isSafeNumber(val)) {
      return this.state.value || null;
    }

    return formatTime(val);
  }
}

```

`packages\tgui\components\Tooltip.tsx`

```tsx
import { createPopper, Placement, VirtualElement } from "@popperjs/core";
import { Component, findDOMFromVNode, InfernoNode, render } from "inferno";

type TooltipProps = {
  children?: InfernoNode;
  content: InfernoNode;
  position?: Placement;
};

type TooltipState = {
  hovered: boolean;
};

const DEFAULT_OPTIONS = {
  modifiers: [
    {
      name: "eventListeners",
      enabled: false,
    },
  ],
};

export class Tooltip extends Component<TooltipProps, TooltipState> {
  // Mounting poppers is really laggy because popper.js is very slow.
  // Thus, instead of using the Popper component, Tooltip creates ONE popper
  // and stores every tooltip inside that.
  // This means you can never have two tooltips at once, for instance.
  static renderedTooltip: HTMLDivElement | undefined;
  static singletonPopper: ReturnType<typeof createPopper> | undefined;
  static currentHoveredElement: Element | undefined;
  static virtualElement: VirtualElement = {
    getBoundingClientRect: () =>
      Tooltip.currentHoveredElement?.getBoundingClientRect() ??
      new DOMRect(0, 0, 0, 0),
  };

  getDOMNode() {
    // HACK: We don't want to create a wrapper, as it could break the layout
    // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
    // My attempt to avoid this was a render prop that passed in
    // callbacks to onmouseenter and onmouseleave, but this was unwiedly
    // to consumers, specifically buttons.
    // This code is copied from `findDOMNode` in inferno-extras.
    // Because this component is written in TypeScript, we will know
    // immediately if this internal variable is removed.
    return findDOMFromVNode(this.$LI, true);
  }

  componentDidMount() {
    const domNode = this.getDOMNode();

    if (!domNode) {
      return;
    }

    domNode.addEventListener("mouseenter", () => {
      let renderedTooltip = Tooltip.renderedTooltip;
      if (renderedTooltip === undefined) {
        renderedTooltip = document.createElement("div");
        renderedTooltip.className = "Tooltip";
        document.body.appendChild(renderedTooltip);
        Tooltip.renderedTooltip = renderedTooltip;
      }

      Tooltip.currentHoveredElement = domNode;

      renderedTooltip.style.opacity = "1";

      this.renderPopperContent();
    });

    domNode.addEventListener("mouseleave", () => {
      this.fadeOut();
    });
  }

  fadeOut() {
    if (Tooltip.currentHoveredElement !== this.getDOMNode()) {
      return;
    }

    Tooltip.currentHoveredElement = undefined;
    Tooltip.renderedTooltip!.style.opacity = "0";
  }

  renderPopperContent() {
    const renderedTooltip = Tooltip.renderedTooltip;
    if (!renderedTooltip) {
      return;
    }

    render(
      <span>{this.props.content}</span>,
      renderedTooltip,
      () => {
        let singletonPopper = Tooltip.singletonPopper;
        if (singletonPopper === undefined) {
          singletonPopper = createPopper(
            Tooltip.virtualElement,
            renderedTooltip!,
            {
              ...DEFAULT_OPTIONS,
              placement: this.props.position || "auto",
            }
          );

          Tooltip.singletonPopper = singletonPopper;
        } else {
          singletonPopper.setOptions({
            ...DEFAULT_OPTIONS,
            placement: this.props.position || "auto",
          });

          singletonPopper.update();
        }
      },
      this.context
    );
  }

  componentDidUpdate() {
    if (Tooltip.currentHoveredElement !== this.getDOMNode()) {
      return;
    }

    this.renderPopperContent();
  }

  componentWillUnmount() {
    this.fadeOut();
  }

  render() {
    return this.props.children;
  }
}

```

`packages\tgui\components\index.js`

```javascript
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export { AnimatedNumber } from "./AnimatedNumber";
export { Autofocus } from "./Autofocus";
export { Blink } from "./Blink";
export { BlockQuote } from "./BlockQuote";
export { Box } from "./Box";
export { Button } from "./Button";
export { ByondUi } from "./ByondUi";
export { Chart } from "./Chart";
export { Collapsible } from "./Collapsible";
export { ColorBox } from "./ColorBox";
export { Dimmer } from "./Dimmer";
export { Divider } from "./Divider";
export { DraggableControl } from "./DraggableControl";
export { Dropdown } from "./Dropdown";
export { Flex } from "./Flex";
export { Grid } from "./Grid";
export { Icon } from "./Icon";
export { InfinitePlane } from "./InfinitePlane";
export { Interactive } from "./Interactive";
export { Input } from "./Input";
export { Knob } from "./Knob";
export { LabeledControls } from "./LabeledControls";
export { LabeledList } from "./LabeledList";
export { Modal } from "./Modal";
export { NoticeBox } from "./NoticeBox";
export { NumberInput } from "./NumberInput";
export { ProgressBar } from "./ProgressBar";
export { Popper } from "./Popper";
export { Pointer } from "./Pointer";
export { RestrictedInput } from "./RestrictedInput";
export { RoundGauge } from "./RoundGauge";
export { Section } from "./Section";
export { Slider } from "./Slider";
export { Stack } from "./Stack";
export { Table } from "./Table";
export { Tabs } from "./Tabs";
export { TextArea } from "./TextArea";
export { TimeDisplay } from "./TimeDisplay";
export { Tooltip } from "./Tooltip";

```

`packages\tgui\styles\atomic\candystripe.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.candystripe:nth-child(odd) {
  background-color: rgba(0, 0, 0, 0.25);
}

```

`packages\tgui\styles\atomic\color.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../colors.scss';

$fg-map: colors.$fg-map !default;
$bg-map: colors.$bg-map !default;

@each $color-name, $color-value in $fg-map {
  .color-#{$color-name} {
    color: $color-value !important;
  }
}

@each $color-name, $color-value in $bg-map {
  .color-bg-#{$color-name} {
    background-color: $color-value !important;
  }
}

```

`packages\tgui\styles\atomic\debug-layout.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.debug-layout,
.debug-layout *:not(g):not(path) {
  color: rgba(255, 255, 255, 0.9) !important;
  background: transparent !important;
  outline: 1px solid rgba(255, 255, 255, 0.5) !important;
  box-shadow: none !important;
  filter: none !important;

  &:hover {
    outline-color: rgba(255, 255, 255, 0.8) !important;
  }
}

```

`packages\tgui\styles\atomic\links.scss`

```scss
@use '../colors.scss';

a {
  &:link,
  &:visited {
    color: colors.$blue;
  }
  &:hover,
  &:active {
    color: colors.$primary;
  }
}

```

`packages\tgui\styles\atomic\outline.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../colors.scss';

.outline-dotted {
  outline-style: dotted !important;
}

.outline-dashed {
  outline-style: dashed !important;
}

.outline-solid {
  outline-style: solid !important;
}

.outline-double {
  outline-style: double !important;
}

.outline-groove {
  outline-style: groove !important;
}

.outline-ridge {
  outline-style: ridge !important;
}

.outline-inset {
  outline-style: inset !important;
}

.outline-outset {
  outline-style: outset !important;
}

$fg-map: colors.$fg-map !default;
$bg-map: colors.$bg-map !default;

@each $color-name, $color-value in $fg-map {
  .outline-color-#{$color-name} {
    outline: 0.167rem solid $color-value !important;
  }
}

```

`packages\tgui\styles\atomic\text.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.text-left {
  text-align: left;
}

.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.text-baseline {
  text-align: baseline;
}

.text-justify {
  text-align: justify;
}

.text-nowrap {
  white-space: nowrap;
}

.text-pre {
  white-space: pre;
}

.text-bold {
  font-weight: bold;
}

.text-italic {
  font-style: italic;
}

.text-underline {
  text-decoration: underline;
}

```

`packages\tgui\styles\base.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:math';
@use 'sass:color';

$color-fg: #ffffff !default;
$color-bg: #252525 !default;
$color-bg-section: rgba(0, 0, 0, 0.33) !default;
$color-bg-grad-spread: 2% !default;
$color-bg-start: color.adjust(
  $color-bg,
  $lightness: $color-bg-grad-spread
) !default;
$color-bg-end: color.adjust(
  $color-bg,
  $lightness: -$color-bg-grad-spread
) !default;

$unit: 12px;
$font-size: 1 * $unit !default;
$border-radius: 0.16em !default;

@function em($px) {
  @return 1em * math.div($px, $unit);
}

@function rem($px) {
  @return 1rem * math.div($px, $unit);
}

```

`packages\tgui\styles\colors.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use 'sass:map';
@use 'sass:meta';

// Base colors
$black: #000000 !default;
$white: #ffffff !default;
$red: #db2828 !default;
$orange: #f2711c !default;
$yellow: #fbd608 !default;
$olive: #b5cc18 !default;
$green: #20b142 !default;
$teal: #00b5ad !default;
$blue: #2185d0 !default;
$violet: #6435c9 !default;
$purple: #a333c8 !default;
$pink: #e03997 !default;
$brown: #a5673f !default;
$grey: #767676 !default;

$primary: #4972a1 !default;
$good: #5baa27 !default;
$average: #f08f11 !default;
$bad: #db2828 !default;
$label: #7e90a7 !default;

// Background and foreground color lightness ratios
$bg-lightness: -15% !default;
$fg-lightness: 10% !default;

@function bg($color) {
  @return color.scale($color, $lightness: $bg-lightness);
}

@function fg($color) {
  @return color.scale($color, $lightness: $fg-lightness);
}

// Mappings of color names

$_gen_map: (
  'black': $black,
  'white': $white,
  'red': $red,
  'orange': $orange,
  'yellow': $yellow,
  'olive': $olive,
  'green': $green,
  'teal': $teal,
  'blue': $blue,
  'violet': $violet,
  'purple': $purple,
  'pink': $pink,
  'brown': $brown,
  'grey': $grey,
  'good': $good,
  'average': $average,
  'bad': $bad,
  'label': $label,
);

// Foreground color names for which to generate a color map
$fg-map-keys: map.keys($_gen_map) !default;
// Background color names for which to generate a color map
$bg-map-keys: map.keys($_gen_map) !default;

$fg-map: ();
@each $color-name in $fg-map-keys {
  $fg-map: map.merge(
    $fg-map,
    (
      $color-name: fg(map.get($_gen_map, $color-name)),
    )
  );
}

$bg-map: ();
@each $color-name in $bg-map-keys {
  $bg-map: map.merge(
    $bg-map,
    (
      $color-name: bg(map.get($_gen_map, $color-name)),
    )
  );
}

```

`packages\tgui\styles\components\BlockQuote.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../colors.scss';

$color-default: colors.fg(colors.$label) !default;

.BlockQuote {
  color: $color-default;
  border-left: base.em(2px) solid $color-default;
  padding-left: 0.5em;
  margin-bottom: 0.5em;

  &:last-child {
    margin-bottom: 0;
  }
}

```

`packages\tgui\styles\components\Button.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../colors.scss';
@use '../functions.scss' as *;

$color-default: colors.bg(colors.$primary) !default;
$color-disabled: #999999 !default;
$color-selected: colors.bg(colors.$green) !default;
$color-caution: colors.bg(colors.$yellow) !default;
$color-danger: colors.bg(colors.$red) !default;
$color-transparent-text: rgba(255, 255, 255, 0.5) !default;
$border-radius: base.$border-radius !default;
$bg-map: colors.$bg-map !default;

@mixin button-color($color) {
  // Adapt text color to background luminance to ensure high contast
  $luminance: luminance($color);
  $text-color: if(sass($luminance > 0.4): rgba(0, 0, 0, 1); else: rgba(255, 255, 255, 1));

  transition: color 50ms, background-color 50ms;
  background-color: $color;
  color: $text-color;

  &:hover {
    transition: color 0ms, background-color 0ms;
  }

  &:focus {
    transition: color 100ms, background-color 100ms;
  }

  &:hover,
  &:focus {
    background-color: lighten($color, 30%);
    color: $text-color;
  }
}

.Button {
  position: relative;
  display: inline-block;
  line-height: 1.667em;
  padding: 0 0.5em;
  margin-right: base.em(2px);
  white-space: nowrap;
  outline: 0;
  border-radius: $border-radius;
  margin-bottom: base.em(2px);
  // Disable selection in buttons
  user-select: none;
  -ms-user-select: none;

  &:last-child {
    margin-right: 0;
    margin-bottom: 0;
  }

  .fa,
  .fas,
  .far {
    margin-left: -0.25em;
    margin-right: -0.25em;
    min-width: 1.333em;
    text-align: center;
  }
}

.Button--hasContent {
  // Add a margin to the icon to keep it separate from the text
  .fa,
  .fas,
  .far {
    margin-right: 0.25em;
  }
}

.Button--hasContent.Button--iconPosition--right {
  .fa,
  .fas,
  .far {
    margin-right: 0px;
    margin-left: 3px;
  }
}

.Button--ellipsis {
  overflow: hidden;
  text-overflow: ellipsis;
}

.Button--fluid {
  display: block;
  margin-left: 0;
  margin-right: 0;
}

.Button--circular {
  border-radius: 50%;
}

.Button--compact {
  padding: 0 0.25em;
  line-height: 1.333em;
}

@each $color-name, $color-value in $bg-map {
  .Button--color--#{$color-name} {
    @include button-color($color-value);
  }
}

.Button--color--default {
  @include button-color($color-default);
}

.Button--color--caution {
  @include button-color($color-caution);
}

.Button--color--danger {
  @include button-color($color-danger);
}

.Button--color--transparent {
  @include button-color(base.$color-bg);
  background-color: rgba(base.$color-bg, 0);
  color: $color-transparent-text;
}

.Button--disabled {
  background-color: $color-disabled !important;
}

.Button--selected {
  @include button-color($color-selected);
}

.Button--segmented {
  margin: 0;
  border-radius: 0;
  cursor: pointer;

  &:first-child {
    border-radius: $border-radius 0 0 $border-radius;
  }

  &:last-child {
    border-radius: 0 $border-radius $border-radius 0;
  }
}

```

`packages\tgui\styles\components\ColorBox.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.ColorBox {
  display: inline-block;
  width: 1em;
  height: 1em;
  line-height: 1em;
  text-align: center;
}

```

`packages\tgui\styles\components\Dimmer.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.Dimmer {
  // Align everything in the middle.
  // A fat middle finger for anything less than IE11.
  display: flex;
  justify-content: center;
  align-items: center;
  // Fill positioned parent
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  // Dim everything around it
  background-color: rgba(0, 0, 0, 0.75);
  z-index: 1;
}

```

`packages\tgui\styles\components\Divider.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';

$color: rgba(255, 255, 255, 0.1) !default;
$thickness: base.em(2px) !default;
$spacing: 0.5em;

.Divider--horizontal {
  margin: $spacing 0;

  &:not(.Divider--hidden) {
    border-top: $thickness solid $color;
  }
}

.Divider--vertical {
  height: 100%;
  margin: 0 $spacing;

  &:not(.Divider--hidden) {
    border-left: $thickness solid $color;
  }
}

```

`packages\tgui\styles\components\Dropdown.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';

.Dropdown {
  position: relative;
  display: inline-block;
}

.Dropdown__control {
  position: relative;
  display: inline-block;
  font-family: Verdana, sans-serif;
  font-size: base.em(12px);
  min-width: base.em(100px);
  line-height: base.em(17px);
  user-select: none;
  pointer-events: none; // clicks pass through to the native select beneath
}

.Dropdown__arrow-button {
  float: right;
  padding-left: 0.35em;
  width: 1.2em;
  height: base.em(22px);
  border-left: base.em(1px) solid #000;
  border-left: base.em(1px) solid rgba(0, 0, 0, 0.25);
}

.Dropdown__selected-text {
  display: inline-block;
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
  height: base.em(17px);
  width: calc(100% - 1.2em);
}

// Invisible native <select> stacked on top of .Dropdown__control.
// The browser handles all dropdown positioning, scrolling, and viewport clamping.
// background-color / color here style the popup list in Chromium-based browsers.
.Dropdown__native {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: pointer;
  z-index: 1;
  font-family: Verdana, sans-serif;
  font-size: base.em(12px);
  box-sizing: border-box;
  background-color: #1a1c22;
  color: #dde4f0;

  &:disabled {
    cursor: default;
  }
}

.Dropdown__native option {
  background-color: #1a1c22;
  color: #dde4f0;
}

.Dropdown__native option:checked {
  background-color: #2a3a5a;
  color: #e8f0ff;
}

```

`packages\tgui\styles\components\FlatGauge.scss`

```scss
.FlatGauge {
  padding: 0.625rem 0.625rem 0.5rem 0.625rem;
  border-radius: 0.75rem;
  background: linear-gradient(180deg, rgba(10, 18, 12, 0.40), rgba(0, 0, 0, 0.35));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255, 255, 255, 0.06),
    inset 0 0 1.875rem rgba(0, 0, 0, 0.55);
}

.FlatGauge__head { margin-bottom: 0.5rem; }

.FlatGauge__title {
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  opacity: 0.85;
  font-size: 0.6875rem;
}

.FlatGauge__readout {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-weight: 900;
  letter-spacing: 0.06em;
  padding: 0.125rem 0.5rem;
  border-radius: 0.4375rem;
  background: rgba(0, 0, 0, 0.35);
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  box-shadow: inset 0 0 0 0.0625rem rgba(0, 0, 0, 0.35);
}

.FlatGauge__readout--good { color: var(--ind-good, rgba(140, 255, 180, 0.95)); }
.FlatGauge__readout--average { color: var(--ind-avg, rgba(240, 200, 80, 0.95)); }
.FlatGauge__readout--bad { color: var(--ind-bad, rgba(255, 110, 110, 0.95)); }

.FlatGauge__unit { opacity: 0.75; font-weight: 800; }


.FlatGauge__track {
  position: relative;
  height: 1rem;
  border-radius: 0.625rem;
  overflow: visible; /* теперь можно, скругление держим на clip-слое */
  background: linear-gradient(180deg, rgba(70, 70, 70, 0.26), rgba(10, 10, 10, 0.40));
  box-shadow:
    inset 0 0 0.75rem rgba(0, 0, 0, 0.70),
    inset 0 0 0 0.0625rem rgba(255, 255, 255, 0.06);
}

.FlatGauge__trackClip {
  position: absolute;
  inset: 0;
  border-radius: inherit;
  overflow: hidden;     /* вот здесь сохраняется скругление и клип зон/тиков/глосса */
}

/* чтобы слои внутри clip корректно якорились */
.FlatGauge__trackClip > .FlatGauge__zone,
.FlatGauge__trackClip > .FlatGauge__ticks,
.FlatGauge__trackClip > .FlatGauge__gloss {
  position: absolute;
}


.FlatGauge__zone {
  position: absolute;
  top: 0;
  bottom: 0;
  opacity: 0.95;
  filter: saturate(1.05);
}

.FlatGauge__zone--z0 { background: rgba(110, 255, 160, 0.35); }
.FlatGauge__zone--z1 { background: rgba(70, 180, 120, 0.28); }
.FlatGauge__zone--z2 { background: rgba(210, 200, 80, 0.30); }
.FlatGauge__zone--z3 { background: rgba(240, 160, 60, 0.30); }
.FlatGauge__zone--z4 { background: rgba(255, 120, 90, 0.30); }
.FlatGauge__zone--z5 { background: rgba(255, 70, 70, 0.32); }

.FlatGauge__ticks {
  position: absolute;
  inset: 0;
  background:
    repeating-linear-gradient(90deg,
      rgba(0, 0, 0, 0) 0,
      rgba(0, 0, 0, 0) 1rem,
      rgba(255, 255, 255, 0.09) 1.0625rem);
  opacity: 0.35;
  mix-blend-mode: overlay;
}

.FlatGauge__gloss {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.18), rgba(255, 255, 255, 0) 55%);
  opacity: 0.22;
}

.FlatGauge__needleWrap {
  position: absolute;
  top: 0;
  transform: translateX(-50%);
  pointer-events: none;
  z-index: 10;
}

.FlatGauge__needle {
  position: absolute;
  left: 0;
  top: 0;
  transform: translate(-50%, calc(-15% - 0.0625rem));
  width: 0;
  height: 0;
  border-left: 0.375rem solid transparent;
  border-right: 0.375rem solid transparent;
  border-top: 0.5625rem solid rgba(235, 235, 235, 0.92);
  filter: drop-shadow(0 0.1875rem 0.375rem rgba(0, 0, 0, 0.60));
  opacity: 0.95;
}

```

`packages\tgui\styles\components\Flex.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.Flex {
  display: -ms-flexbox;
  display: flex;
}

.Flex--inline {
  display: inline-flex;
}

```

`packages\tgui\styles\components\Icon.scss`

```scss
/**
 * @file
 * @copyright 2020
 * @author ThePotato97 (https://github.com/ThePotato97)
 * @license ISC
 */

.IconStack > .Icon {
  position: absolute;
  width: 100%;
  text-align: center;
}

.IconStack {
  position: relative;
  display: inline-block;
  height: 1.2em;
  line-height: 2em;
  vertical-align: middle;

  &:after {
    color: transparent;
    content: '.';
  }
}

```

`packages\tgui\styles\components\Input.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../functions.scss' as *;

$text-color: base.$color-fg !default;
$background-color: #0a0a0a !default;
$border-color: #88bfff !default;
$border-radius: base.$border-radius !default;

.Input {
  position: relative;
  display: inline-block;
  width: base.em(120px);
  border: base.em(1px) solid $border-color;
  border: base.em(1px) solid rgba($border-color, 0.75);
  border-radius: $border-radius;
  color: $text-color;
  background-color: $background-color;
  padding: 0 base.em(4px);
  margin-right: base.em(2px);
  line-height: base.em(17px);
  overflow: visible;
}

.Input--fluid {
  display: block;
  width: auto;
}

.Input__baseline {
  display: inline-block;
  color: transparent;
}

.Input__input {
  display: block;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  border: 0;
  outline: 0;
  width: 100%;
  font-size: base.em(12px);
  line-height: base.em(17px);
  height: base.em(17px);
  margin: 0;
  padding: 0 0.5em;
  font-family: Verdana, sans-serif;
  background-color: transparent;
  color: $text-color;
  color: inherit;

  &:-ms-input-placeholder {
    font-style: italic;
    color: #777;
    color: rgba(255, 255, 255, 0.45);
  }
}

.Input--monospace .Input__input {
  font-family: 'Consolas', monospace;
}

```

`packages\tgui\styles\components\Knob.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../colors.scss';
@use '../functions.scss' as *;

$bg-map: colors.$bg-map !default;
$fg-map: colors.$fg-map !default;
$ring-color: #6a96c9 !default;
$knob-color: #333333 !default;
$popup-background-color: #000000 !default;
$popup-text-color: #ffffff !default;

$inner-padding: 0.1em;

.Knob {
  position: relative;
  font-size: 1rem;
  width: 2.6em;
  height: 2.6em;
  margin: 0 auto;
  margin-bottom: -0.2em;
  cursor: n-resize;

  // Adjusts a baseline in a way, that makes knob middle-aligned
  // when it flows with the text.
  &:after {
    content: '.';
    color: transparent;
    line-height: 2.5em;
  }
}

.Knob__circle {
  position: absolute;
  top: $inner-padding;
  bottom: $inner-padding;
  left: $inner-padding;
  right: $inner-padding;
  margin: 0.3em;
  background-color: $knob-color;
  background-image: linear-gradient(
    to bottom,
    rgba(255, 255, 255, 0.15) 0%,
    rgba(255, 255, 255, 0) 100%
  );
  border-radius: 50%;
  box-shadow: 0 0.05em 0.5em 0 rgba(0, 0, 0, 0.5);
}

.Knob__cursorBox {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
}

.Knob__cursor {
  position: relative;
  top: 0.05em;
  margin: 0 auto;
  width: 0.2em;
  height: 0.8em;
  background-color: rgba(255, 255, 255, 0.9);
}

.Knob__popupValue {
  position: absolute;
  top: -2rem;
  right: 50%;
  font-size: 1rem;
  text-align: center;
  padding: 0.25rem 0.5rem;
  color: $popup-text-color;
  background-color: $popup-background-color;
  transform: translateX(50%);
  white-space: nowrap;
}

.Knob__ring {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  padding: $inner-padding;
}

$pi: 3.1416;

.Knob__ringTrackPivot {
  transform: rotateZ(135deg);
}

.Knob__ringTrack {
  // transform-origin: 50% 50%;
  fill: transparent;
  stroke: rgba(255, 255, 255, 0.1);
  stroke-width: 8;
  stroke-linecap: round;
  stroke-dasharray: 75 * $pi;
}

.Knob__ringFillPivot {
  transform: rotateZ(135deg);
}

.Knob--bipolar .Knob__ringFillPivot {
  transform: rotateZ(270deg);
}

.Knob__ringFill {
  fill: transparent;
  stroke: $ring-color;
  stroke-width: 8;
  stroke-linecap: round;
  stroke-dasharray: 100 * $pi;
  transition: stroke 50ms ease-out;
}

@each $color-name, $color-value in $fg-map {
  .Knob--color--#{$color-name} {
    .Knob__ringFill {
      stroke: $color-value;
    }
  }
}

```

`packages\tgui\styles\components\LabeledList.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';

.LabeledList {
  display: table;
  // IE8: Does not support calc
  width: 100%;
  // Compensate for negative margin
  width: calc(100% + 1em);
  border-collapse: collapse;
  border-spacing: 0;
  margin: -0.25em -0.5em;
  margin-bottom: 0;
  padding: 0;
}

.LabeledList__row {
  display: table-row;
}

.LabeledList__row:last-child .LabeledList__cell {
  padding-bottom: 0;
}

.LabeledList__cell {
  display: table-cell;
  margin: 0;
  padding: 0.25em 0.5em;
  border: 0;
  text-align: left;
  vertical-align: baseline;
}

.LabeledList__label {
  width: 1%;
  white-space: nowrap;
  min-width: 5em;
}

.LabeledList__buttons {
  width: 0.1%;
  white-space: nowrap;
  text-align: right;
  padding-top: base.em(1px);
  padding-bottom: 0;
}

```

`packages\tgui\styles\components\Modal.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';

$background-color: base.$color-bg !default;

.Modal {
  background-color: $background-color;
  max-width: calc(100% - 1rem);
  padding: 1rem;
}

```

`packages\tgui\styles\components\NoticeBox.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use '../base.scss';
@use '../colors.scss';
@use '../functions.scss' as *;

// NoticeBox
$background-color: #bb9b68 !default;
$color-stripes: rgba(0, 0, 0, 0.1) !default;
$color-border: #272727 !default;
$bg-map: colors.$bg-map !default;

.NoticeBox {
  // Adapt text color to background luminance to ensure high contast
  $luminance: luminance($background-color);
  $text-color: if(sass($luminance > 0.35): rgba(0, 0, 0, 1); else: rgba(255, 255, 255, 1));

  padding: 0.33em 0.5em;
  margin-bottom: 0.5em;
  box-shadow: none;
  font-weight: bold;
  font-style: italic;
  color: $text-color;
  background-color: $background-color;
  background-image: repeating-linear-gradient(
    -45deg,
    transparent,
    transparent base.em(10px),
    $color-stripes base.em(10px),
    $color-stripes base.em(20px)
  );
}

@mixin box-color($color) {
  $luminance: luminance($color);
  $text-color: if(sass($luminance > 0.35): rgba(0, 0, 0, 1); else: rgba(255, 255, 255, 1));
  color: $text-color;
  background-color: color.adjust($color, $saturation: -15%, $lightness: -15%);
}

@each $color-name, $color-value in $bg-map {
  .NoticeBox--color--#{$color-name} {
    @include box-color($color-value);
  }
}

.NoticeBox--type--info {
  @include box-color(colors.$blue);
}

.NoticeBox--type--success {
  @include box-color(colors.$green);
}

.NoticeBox--type--warning {
  @include box-color(colors.$orange);
}

.NoticeBox--type--danger {
  @include box-color(colors.$red);
}

```

`packages\tgui\styles\components\NumberInput.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use '../base.scss';
@use '../functions.scss' as *;
@use './Input.scss';

$text-color: Input.$text-color !default;
$background-color: Input.$background-color !default;
$border-color: Input.$border-color !default;
$border-radius: Input.$border-radius !default;

.NumberInput {
  position: relative;
  display: inline-block;
  border: base.em(1px) solid $border-color;
  border: base.em(1px) solid rgba($border-color, 0.75);
  border-radius: $border-radius;
  color: $border-color;
  background-color: $background-color;
  padding: 0 base.em(4px);
  margin-right: base.em(2px);
  line-height: base.em(17px);
  text-align: right;
  overflow: visible;
  cursor: n-resize;
}

.NumberInput--fluid {
  display: block;
}

.NumberInput__content {
  margin-left: 0.5em;
}

.NumberInput__barContainer {
  position: absolute;
  top: base.em(2px);
  bottom: base.em(2px);
  left: base.em(2px);
}

.NumberInput__bar {
  position: absolute;
  bottom: 0;
  left: 0;
  width: base.em(3px);
  box-sizing: border-box;
  border-bottom: base.em(1px) solid $border-color;
  background-color: $border-color;
}

.NumberInput__input {
  display: block;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  border: 0;
  outline: 0;
  width: 100%;
  font-size: base.em(12px);
  line-height: base.em(17px);
  height: base.em(17px);
  margin: 0;
  padding: 0 0.5em;
  font-family: Verdana, sans-serif;
  background-color: $background-color;
  color: $text-color;
  text-align: right;
}

```

`packages\tgui\styles\components\ProgressBar.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../colors.scss';
@use '../functions.scss' as *;

$color-default-fill: colors.bg(colors.$primary) !default;
$background-color: rgba(0, 0, 0, 0) !default;
$border-radius: base.$border-radius !default;
$bg-map: colors.$bg-map !default;

.ProgressBar {
  display: inline-block;
  position: relative;
  width: 100%;
  padding: 0 0.5em;
  border-radius: $border-radius;
  background-color: $background-color;
  transition: border-color 900ms ease-out;
}

.ProgressBar__fill {
  position: absolute;
  top: -0.5px;
  left: 0px;
  bottom: -0.5px;
}

.ProgressBar__fill--animated {
  transition: background-color 900ms ease-out, width 900ms ease-out;
}

.ProgressBar__content {
  position: relative;
  line-height: base.em(17px);
  width: 100%;
  text-align: right;
}

.ProgressBar--color--default {
  border: base.em(1px) solid $color-default-fill;

  .ProgressBar__fill {
    background-color: $color-default-fill;
  }
}

@each $color-name, $color-value in $bg-map {
  .ProgressBar--color--#{$color-name} {
    border: base.em(1px) solid $color-value !important;

    .ProgressBar__fill {
      background-color: $color-value;
    }
  }
}

```

`packages\tgui\styles\components\RockerSwitch.scss`

```scss
.RockerSwitch__row { gap: 0.75rem; }

.RockerSwitch__label {
  font-weight: 900;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  opacity: 0.92;
  font-size: 0.6875rem;
}

.RockerSwitch {
  position: relative;
  width: 7.5rem;
  height: 2.25rem;
  border-radius: 0.75rem;

  background:
    radial-gradient(13.75rem 2.75rem at 30% 18%, rgba(255, 255, 255, 0.16), rgba(0, 0, 0, 0) 58%),
    linear-gradient(180deg, rgba(90, 90, 90, 0.55), rgba(10, 10, 10, 0.82));

  box-shadow:
    inset 0 0.0625rem 0 rgba(255, 255, 255, 0.16),
    inset 0 -1.125rem 1.625rem rgba(0, 0, 0, 0.52),
    inset 0 0 0 0.0625rem rgba(255, 255, 255, 0.08),
    0 0.625rem 1.125rem rgba(0, 0, 0, 0.40);

  overflow: hidden;
  user-select: none;
}

.RockerSwitch__rail {
  position: absolute;
  inset: 0.4375rem 0.4375rem;
  border-radius: 0.625rem;
  background: linear-gradient(180deg, rgba(0, 0, 0, 0.55), rgba(255, 255, 255, 0.03));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255, 255, 255, 0.06),
    inset 0 0 1.125rem rgba(0, 0, 0, 0.70);
}

.RockerSwitch__handle {
  position: absolute;
  top: 0.4375rem;
  bottom: 0.4375rem;
  width: 3.25rem;
  left: 0.4375rem;
  border-radius: 0.625rem;

  background:
    radial-gradient(circle at 28% 28%, rgba(255, 255, 255, 0.92), rgba(185, 185, 185, 0.52) 56%, rgba(18, 18, 18, 0.75) 100%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.10), rgba(0, 0, 0, 0.25));

  box-shadow:
    0 0.625rem 0.875rem rgba(0, 0, 0, 0.55),
    inset 0 0 0 0.0625rem rgba(0, 0, 0, 0.42),
    inset 0 0.625rem 0.875rem rgba(255, 255, 255, 0.06);

  transition: transform 160ms cubic-bezier(.2,.9,.2,1.1), filter 120ms ease;
  will-change: transform;
}

.RockerSwitch__labels--2 {
  position: absolute;
  inset: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  text-align: center;
  font-weight: 900;
  letter-spacing: 0.10em;
  font-size: 0.6875rem;
  text-transform: uppercase;
  opacity: 0.92;
  pointer-events: none;
}

.RockerSwitch__lab { opacity: 0.72; }
.RockerSwitch--on  .RockerSwitch__lab--on  { opacity: 1; color: var(--ind-good, rgba(140, 255, 180, 0.95)); }
.RockerSwitch--on  .RockerSwitch__lab--off { opacity: 0.55; }
.RockerSwitch--off .RockerSwitch__lab--on  { opacity: 0.55; color: var(--ind-good, rgba(140, 255, 180, 0.95)); }
.RockerSwitch--off .RockerSwitch__lab--off { opacity: 1; color: rgba(202, 60, 60, 0.92); }

.RockerSwitch__hit--2 {
  position: absolute;
  inset: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
}
.RockerSwitch__hitZone { cursor: pointer; }
.RockerSwitch--disabled .RockerSwitch__hitZone { cursor: default; }

.RockerSwitch--on  .RockerSwitch__handle { transform: translateX(0); }
.RockerSwitch--off .RockerSwitch__handle { transform: translateX(3.375rem); }

.RockerSwitch--danger.RockerSwitch--on .RockerSwitch__lab--on { color: var(--ind-bad, rgba(255, 110, 110, 0.95)); }
.RockerSwitch--disabled { opacity: 0.45; filter: grayscale(0.55); }
.RockerSwitch--anim .RockerSwitch__handle { filter: brightness(1.06); }

```

`packages\tgui\styles\components\RoundGauge.scss`

```scss
/**
 * Copyright (c) 2020 bobbahbrown (https://github.com/bobbahbrown)
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../colors.scss';
@use '../functions.scss' as *;

$fg-map: colors.$fg-map !default;
$ring-color: #6a96c9 !default;

.RoundGauge {
  font-size: 1rem;
  width: 2.6em;
  height: 1.3em;
  margin: 0 auto;
  margin-bottom: 0.2em;
}

$pi: 3.1416;

.RoundGauge__ringTrack {
  fill: transparent;
  stroke: rgba(255, 255, 255, 0.1);
  stroke-width: 10;
  stroke-dasharray: 50 * $pi;
  stroke-dashoffset: 50 * $pi;
}

.RoundGauge__ringFill {
  fill: transparent;
  stroke: $ring-color;
  stroke-width: 10;
  stroke-dasharray: 100 * $pi;
  transition: stroke 50ms ease-out;
}

.RoundGauge__needle,
.RoundGauge__ringFill {
  transition: transform 50ms ease-in-out;
}

.RoundGauge__needleLine,
.RoundGauge__needleMiddle {
  fill: colors.$bad;
}

.RoundGauge__alert {
  fill-rule: evenodd;
  clip-rule: evenodd;
  stroke-linejoin: round;
  stroke-miterlimit: 2;
  fill: rgba(255, 255, 255, 0.1);
}

.RoundGauge__alert.max {
  fill: colors.$bad;
}

@each $color-name, $color-value in $fg-map {
  .RoundGauge--color--#{$color-name}.RoundGauge__ringFill {
    stroke: $color-value;
  }
}

@each $color-name, $color-value in $fg-map {
  .RoundGauge__alert--#{$color-name} {
    fill: $color-value;
    transition: opacity 0.6s cubic-bezier(0.25, 1, 0.5, 1);
    animation: RoundGauge__alertAnim
      1s
      cubic-bezier(0.34, 1.56, 0.64, 1)
      infinite;
  }
}

@keyframes RoundGauge__alertAnim {
  0% {
    opacity: 0.1;
  }
  50% {
    opacity: 1;
  }
  100% {
    opacity: 0.1;
  }
}

```

`packages\tgui\styles\components\Section.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use '../base.scss';
@use '../colors.scss';
@use '../functions.scss';

$title-text-color: base.$color-fg !default;
$background-color: base.$color-bg-section !default;
$separator-color: colors.$primary !default;

.Section {
  position: relative;
  margin-bottom: 0.5em;
  background-color: functions.fake-alpha($background-color, base.$color-bg);
  background-color: $background-color;
  box-sizing: border-box;

  &:last-child {
    margin-bottom: 0;
  }
}

.Section__title {
  position: relative;
  padding: 0.5em;
  border-bottom: base.em(2px) solid $separator-color;
}

.Section__titleText {
  font-size: base.em(14px);
  font-weight: bold;
  color: $title-text-color;
}

.Section__buttons {
  position: absolute;
  display: inline-block;
  right: 0.5em;
  margin-top: base.em(-1px);
}

.Section__rest {
  position: relative;
}

.Section__content {
  padding: 0.66em 0.5em;
}

.Section--fitted > .Section__rest > .Section__content {
  padding: 0;
}

.Section--fill {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.Section--fill > .Section__rest {
  flex-grow: 1;
}

.Section--fill > .Section__rest > .Section__content {
  height: 100%;
}

.Section--fill.Section--scrollable > .Section__rest > .Section__content {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

.Section--scrollable {
  overflow-x: hidden;
  overflow-y: hidden;

  & > .Section__rest > .Section__content {
    overflow-y: scroll;
    overflow-x: hidden;
  }
}

// Nested sections
.Section .Section {
  background-color: transparent;
  margin-left: -0.5em;
  margin-right: -0.5em;

  // Remove extra space above the first nested section
  &:first-child {
    margin-top: -0.5em;
  }
}

// Level 2 section title
.Section .Section .Section__titleText {
  font-size: base.em(13px);
}

// Level 3 section title
.Section .Section .Section .Section__titleText {
  font-size: base.em(12px);
}

```

`packages\tgui\styles\components\Seg7.scss`

```scss
/* Theme-driven 7-seg display */
/* Uses .theme-industrial tokens but degrades gracefully */

.Seg7 {
  --seg-on: var(--ind-seg-on, rgba(140, 255, 190, 0.95));
  --seg-glow: var(--ind-seg-glow, rgba(140, 255, 190, 0.22));
  --seg-off: var(--ind-seg-off, rgba(60, 140, 90, 0.18));

  border-radius: 0.625rem;
  padding: 0.625rem 0.625rem 0.5rem 0.625rem;
}

.Seg7--sm {
  padding: 0.5rem 0.5rem 0.375rem 0.5rem;
  border-radius: 0.5625rem;
}

.Seg7__label {
  text-transform: uppercase;
  letter-spacing: 0.14em;
  font-weight: 900;
  font-size: 0.6875rem;
  opacity: 0.78;
  margin-bottom: 0.375rem;
}

.Seg7--sm .Seg7__label {
  font-size: 0.625rem;
  margin-bottom: 0.25rem;
}

.Seg7__body {
  border-radius: 0.5rem;
  padding: 0.5rem 0.5rem 0.375rem 0.5rem;
  background: rgba(0, 0, 0, 0.25);
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255, 255, 255, 0.06),
    inset 0 0 1.25rem rgba(0, 0, 0, 0.65);
}

.Seg7__digits { align-items: center; }

.Seg7__unit {
  margin-top: 0.125rem;
  font-weight: 900;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  opacity: 0.65;
  font-size: 0.6875rem;
}

.Seg7--sm .Seg7__unit { font-size: 0.625rem; }

.Seg7--c-green { --seg-on: rgba(140, 255, 190, 0.95); --seg-glow: rgba(140, 255, 190, 0.22); --seg-off: rgba(60, 140, 90, 0.18); }
.Seg7--c-cyan  { --seg-on: rgba(140, 220, 255, 0.95); --seg-glow: rgba(140, 220, 255, 0.20); --seg-off: rgba(70, 110, 140, 0.18); }
.Seg7--c-amber { --seg-on: rgba(255, 230, 140, 0.95); --seg-glow: rgba(255, 220, 120, 0.18); --seg-off: rgba(140, 120, 70, 0.18); }
.Seg7--c-red   { --seg-on: rgba(255, 150, 150, 0.95); --seg-glow: rgba(255, 120, 120, 0.18); --seg-off: rgba(140, 70, 70, 0.18); }
.Seg7--c-white { --seg-on: rgba(235, 235, 235, 0.92); --seg-glow: rgba(255, 255, 255, 0.12); --seg-off: rgba(120, 120, 120, 0.18); }

.Seg7--warning {
  --seg-on: rgba(255, 210, 80, 0.98);
  --seg-glow: rgba(255, 180, 60, 0.35);
  animation: segPulse 1.8s ease-in-out infinite !important;
}

/* Danger = strong red */
.Seg7--danger {
  --seg-on: rgba(255, 60, 60, 1);
  --seg-glow: rgba(255, 40, 40, 0.45);
  animation: segPulse 0.8s ease-in-out infinite !important;
}

.Seg7__digit {
  position: relative;
  width: 1.5rem;
  height: 2.75rem;
  margin-right: 0.125rem;
  opacity: 0.95;
}

.Seg7--sm .Seg7__digit {
  width: 1.125rem;
  height: 2rem;
  margin-right: 0.0625rem;
}

.Seg7__segment {
  position: absolute;
  background: var(--seg-off);
  border-radius: 0.125rem;
  transition: opacity 0.08s linear, box-shadow 0.08s linear, background 0.08s linear;
  opacity: 0.35;
}
.Seg7__segment::before {
  content: "";
  position: absolute;
  inset: 0;
  clip-path: polygon(10% 0%, 90% 0%, 100% 50%, 90% 100%, 10% 100%, 0% 50%);
}
.Seg7__segment--on {
  opacity: 1;
  background: var(--seg-on);
  box-shadow: 0 0 0.375rem var(--seg-glow), 0 0 1rem rgba(0, 0, 0, 0);
}

.Seg7__segment--a { top: 0.125rem; left: 0.375rem; width: 0.875rem; height: 0.25rem; }
.Seg7__segment--b { top: 0.375rem; right: 0.125rem; width: 0.25rem; height: 1rem; }
.Seg7__segment--c { bottom: 0.375rem; right: 0.125rem; width: 0.25rem; height: 1rem; }
.Seg7__segment--d { bottom: 0.125rem; left: 0.375rem; width: 0.875rem; height: 0.25rem; }
.Seg7__segment--e { bottom: 0.375rem; left: 0.125rem; width: 0.25rem; height: 1rem; }
.Seg7__segment--f { top: 0.375rem; left: 0.125rem; width: 0.25rem; height: 1rem; }
.Seg7__segment--g { top: 1.25rem; left: 0.375rem; width: 0.875rem; height: 0.25rem; }
.Seg7__segment--dp { right: 0.0625rem; bottom: 0.125rem; width: 0.3125rem; height: 0.3125rem; border-radius: 50%; clip-path: none; }

.Seg7--sm .Seg7__segment--a { top: 0.0625rem; left: 0.25rem; width: 0.625rem; height: 0.1875rem; }
.Seg7--sm .Seg7__segment--b { top: 0.25rem; right: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.Seg7--sm .Seg7__segment--c { bottom: 0.25rem; right: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.Seg7--sm .Seg7__segment--d { bottom: 0.0625rem; left: 0.25rem; width: 0.625rem; height: 0.1875rem; }
.Seg7--sm .Seg7__segment--e { bottom: 0.25rem; left: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.Seg7--sm .Seg7__segment--f { top: 0.25rem; left: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.Seg7--sm .Seg7__segment--g { top: 0.875rem; left: 0.25rem; width: 0.625rem; height: 0.1875rem; }

@keyframes indSegFlicker {
  0%   { filter: brightness(1); }
  25%  { filter: brightness(1.08); }
  35%  { filter: brightness(0.95); }
  55%  { filter: brightness(1.10); }
  100% { filter: brightness(1); }
}
.Seg7--pulse .Seg7__segment--on {
  animation: indSegFlicker 0.45s linear infinite;
}

@keyframes segPulse {
  0%, 100% { filter: brightness(1); }
  50% { filter: brightness(1.25); }
}

```

`packages\tgui\styles\components\Slider.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';

$cursor-color: base.$color-fg !default;
$popup-background-color: #000000 !default;
$popup-text-color: #ffffff !default;

.Slider {
  cursor: e-resize;
}

.Slider__cursorOffset {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  transition: none !important;
}

.Slider__cursor {
  position: absolute;
  top: 0;
  right: base.em(-1px);
  bottom: 0;
  width: 0;
  border-left: base.em(2px) solid $cursor-color;
}

.Slider__pointer {
  position: absolute;
  right: base.em(-5px);
  bottom: base.em(-4px);
  width: 0;
  height: 0;
  border-left: base.em(5px) solid transparent;
  border-right: base.em(5px) solid transparent;
  border-bottom: base.em(5px) solid $cursor-color;
}

.Slider__popupValue {
  position: absolute;
  right: 0;
  top: -2rem;
  font-size: 1rem;
  padding: 0.25rem 0.5rem;
  color: $popup-text-color;
  background-color: $popup-background-color;
  transform: translateX(50%);
  white-space: nowrap;
}

```

`packages\tgui\styles\components\Stack.scss`

```scss
/**
 * Copyright (c) 2021 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use './Divider.scss';

.Stack--fill {
  height: 100%;
}

.Stack--horizontal > .Stack__item {
  margin-left: 0.5em;

  &:first-child {
    margin-left: 0;
  }
}

.Stack--vertical > .Stack__item {
  margin-top: 0.5em;

  &:first-child {
    margin-top: 0;
  }
}

.Stack--horizontal > .Stack__divider:not(.Stack__divider--hidden) {
  border-left: Divider.$thickness solid Divider.$color;
}

.Stack--vertical > .Stack__divider:not(.Stack__divider--hidden) {
  border-top: Divider.$thickness solid Divider.$color;
}

```

`packages\tgui\styles\components\Table.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

.Table {
  display: table;
  width: 100%;
  border-collapse: collapse;
  border-spacing: 0;
  margin: 0;
}

.Table--collapsing {
  width: auto;
}

.Table__row {
  display: table-row;
}

.Table__cell {
  display: table-cell;
  padding: 0 0.25em;

  &:first-child {
    padding-left: 0;
  }

  &:last-child {
    padding-right: 0;
  }
}

.Table__row--header .Table__cell,
.Table__cell--header {
  font-weight: bold;
  padding-bottom: 0.5em;
}

.Table__cell--collapsing {
  width: 1%;
  white-space: nowrap;
}

```

`packages\tgui\styles\components\Tabs.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:math';
@use 'sass:color';
@use '../base.scss';
@use '../colors.scss';

$color-default: color.scale(
  colors.fg(colors.$primary),
  $lightness: 75%
) !default;
$text-color: rgba(255, 255, 255, 0.5) !default;
$text-color-selected: color.scale($color-default, $lightness: 25%) !default;
$tab-color: transparent !default;
$tab-color-hovered: rgba(255, 255, 255, 0.075) !default;
$tab-color-selected: rgba(255, 255, 255, 0.125) !default;
$border-radius: base.$border-radius !default;
$fg-map: colors.$fg-map !default;

.Tabs {
  display: flex;
  align-items: stretch;
  overflow: hidden;
  background-color: base.$color-bg-section;
}

.Tabs--fill {
  height: 100%;
}

// Interoperability with sections
.Section .Tabs {
  background-color: transparent;
}

.Section:not(.Section--fitted) .Tabs {
  margin: 0 -0.5em 0.5em;

  &:first-child {
    margin-top: -0.5em;
  }
}

.Tabs--vertical {
  flex-direction: column;
  padding: 0.25em 0 0.25em 0.25em;
}

.Tabs--horizontal {
  margin-bottom: 0.5em;
  padding: 0.25em 0.25em 0 0.25em;

  &:last-child {
    margin-bottom: 0;
  }
}

.Tabs__Tab {
  flex-grow: 0;
}

.Tabs--fluid .Tabs__Tab {
  flex-grow: 1;
}

.Tab {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: $tab-color;
  color: $text-color;
  min-height: 2.25em;
  min-width: 4em;
  transition: background-color 50ms ease-out;
}

.Tab:not(.Tab--selected):hover {
  background-color: $tab-color-hovered;
  transition: background-color 0;
}

.Tab--selected {
  background-color: $tab-color-selected;
  color: $text-color-selected;
}

.Tab__text {
  flex-grow: 1;
  margin: 0 0.5em;
}

.Tab__left {
  min-width: 1.5em;
  text-align: center;
  margin-left: 0.25em;
}

.Tab__right {
  min-width: 1.5em;
  text-align: center;
  margin-right: 0.25em;
}

.Tabs--horizontal {
  .Tab {
    border-top: math.div(1em, 6) solid transparent;
    border-bottom: math.div(1em, 6) solid transparent;
    border-top-left-radius: 0.25em;
    border-top-right-radius: 0.25em;
  }

  .Tab--selected {
    border-bottom: math.div(1em, 6) solid $color-default;
  }
}

.Tabs--vertical {
  .Tab {
    min-height: 2em;
    border-left: math.div(1em, 6) solid transparent;
    border-right: math.div(1em, 6) solid transparent;
    border-top-left-radius: 0.25em;
    border-bottom-left-radius: 0.25em;
  }

  .Tab--selected {
    border-right: math.div(1em, 6) solid $color-default;
  }
}

@each $color-name, $color-value in $fg-map {
  .Tab--selected.Tab--color--#{$color-name} {
    color: color.scale($color-value, $lightness: 25%);
  }

  .Tabs--horizontal .Tab--selected.Tab--color--#{$color-name} {
    border-bottom-color: $color-value;
  }

  .Tabs--vertical .Tab--selected.Tab--color--#{$color-name} {
    border-right-color: $color-value;
  }
}

```

`packages\tgui\styles\components\TextArea.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../functions.scss' as *;
@use './Input.scss';

$text-color: Input.$text-color !default;
$background-color: Input.$background-color !default;
$border-color: Input.$border-color !default;
$border-radius: Input.$border-radius !default;

.TextArea {
  position: relative;
  display: inline-block;
  border: base.em(1px) solid $border-color;
  border: base.em(1px) solid rgba($border-color, 0.75);
  border-radius: $border-radius;
  background-color: $background-color;
  margin-right: base.em(2px);
  line-height: base.em(17px);
  box-sizing: border-box;
  width: 100%;
}

.TextArea--fluid {
  display: block;
  width: auto;
  height: auto;
}

.TextArea__textarea {
  display: block;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  border: 0;
  outline: 0;
  width: 100%;
  height: 100%;
  font-size: 1em;
  line-height: base.em(17px);
  min-height: base.em(17px);
  margin: 0;
  padding: 0 0.5em;
  font-family: inherit;
  background-color: transparent;
  color: inherit;
  box-sizing: border-box;
  // Make sure the div and the textarea wrap words in the same way
  word-wrap: break-word;
  overflow: hidden;

  &:-ms-input-placeholder {
    font-style: italic;
    color: #777;
    color: rgba(255, 255, 255, 0.45);
  }
}

```

`packages\tgui\styles\components\ThermoSlider.scss`

```scss
.ThermoSlider {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.ThermoSlider--disabled {
  opacity: 0.45;
  filter: grayscale(0.55);
}
/* Полоса заполнения (оба слоя) */
.ThermoSlider__control .ProgressBar__fill {
  border-radius: 0.75rem;
}

/* Шкала как раньше */
.ThermoSlider__scale {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-weight: 900;
  letter-spacing: 0.08em;
  font-size: 0.6875rem;
  opacity: 0.72;
  pointer-events: none;
}

.ThermoSlider__scaleMin { text-align: left; }
.ThermoSlider__scaleMid { text-align: center; opacity: 0.65; }
.ThermoSlider__scaleMax { text-align: right; }
.ThermoSlider__row {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.ThermoSlider__control {
  flex: 1 1 auto;
  min-width: 16.25rem;
}

/* Mini display справа */
.ThermoSlider__miniDisplay {
  flex: 0 0 auto;
  min-width: 5.375rem;
  height: 1.875rem;
  padding: 0 0.625rem;
  border-radius: 0.625rem;

  display: inline-flex;
  align-items: center;
  justify-content: center;

  font-family: var(--ind-font-mono);
  font-weight: 900;
  letter-spacing: 0.08em;
  font-size: 0.75rem;

  color: var(--ind-fg);

  background: linear-gradient(180deg, rgba(10,18,12,0.78), rgba(0,0,0,0.84));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.14),
    inset 0 0 1.125rem rgba(0,0,0,0.70),
    0 0.625rem 1.125rem rgba(0,0,0,0.40);

  user-select: none;
}

/* Disabled совпадает с вашим общим disabled */
.ThermoSlider--disabled .ThermoSlider__miniDisplay {
  opacity: 0.55;
  filter: grayscale(0.55);
}

```

`packages\tgui\styles\components\Tooltip.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use '../base.scss';
@use '../functions.scss'as *;

$color: #ffffff !default;
$background-color: #000000 !default;
$border-radius: base.$border-radius !default;

.Tooltip {
  z-index: 2;
  padding: 0.5em 0.75em;
  pointer-events: none;
  text-align: left;
  transition: opacity 150ms ease-out;
  background-color: $background-color;
  color: $color;
  box-shadow: 0.1em 0.1em 1.25em -0.1em rgba(0, 0, 0, 0.5);
  border-radius: $border-radius;
  max-width: base.em(250px);
}

```

`packages\tgui\styles\functions.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use 'sass:map';
@use 'sass:math';
@use 'sass:meta';

//  Type-casting
// --------------------------------------------------------

// Get a unit-less numeric value
@function num($value) {
  @if meta.type-of($value) != number {
    @error 'Could not convert `#{$value}` - must be `type-of number`';
    @return null;
  }
  @if math.unit($value) == '%' {
    @return math.div($value, 100%);
  }
  @return math.div($value, ($value * 0 + 1));
}

//  Color
// --------------------------------------------------------

// Increases perceptual color lightness.
@function lighten($color, $percent) {
  $scaled: hsl(
    color.channel($color, 'hue', $space: hsl),
    color.channel($color, 'saturation', $space: hsl),
    color.channel($color, 'lightness', $space: hsl) * (1 + num($percent))
  );
  $mixed: color.mix(#ffffff, $color, 100% * num($percent));
  @return color.mix($scaled, $mixed, 75%);
}

// Returns the NTSC luminance of `$color` as a float (between 0 and 1).
// 1 is pure white, 0 is pure black.
@function luminance($color) {
  $colors: (
    'red': color.channel($color, 'red', $space: rgb),
    'green': color.channel($color, 'green', $space: rgb),
    'blue': color.channel($color, 'blue', $space: rgb),
  );

  @each $name, $value in $colors {
    $adjusted: 0;
    $value: math.div($value, 255);
    @if $value < 0.03928 {
      $value: math.div($value, 12.92);
    } @else {
      $value: math.div(($value + 0.055), 1.055);
      $value: math.pow($value, 2.4);
    }
    $colors: map.merge(
      $colors,
      (
        $name: $value,
      )
    );
  }

  @return (map.get($colors, 'red') * 0.2126) +
    (map.get($colors, 'green') * 0.7152) + (map.get($colors, 'blue') * 0.0722);
}

// Blends an RGBA color with a static background color based on its
// alpha channel. Returns an RGB color, which is compatible with IE8.
@function fake-alpha($color-rgba, $color-background) {
  @return color.mix(
    color.change($color-rgba, $alpha: 1),
    $color-background,
    color.channel($color-rgba, 'alpha') * 100%
  );
}

```

`packages\tgui\styles\interfaces\AirAlarm.scss`

```scss
/* tgui/interfaces/AirAlarm/AirAlarm.scss
 * AirAlarm layout + local skins.
 * Uses theme tokens from `.theme-industrial` via CSS vars.
 */

.AirAlarm {
  height: 100%;
}

/* ===== Layout resilience ===== */
.AirAlarm__layout {
  min-height: 45rem;
}

@media (max-width: 61.25rem) {
  .AirAlarm__layout { flex-direction: column; }
  .AirAlarm__left,
  .AirAlarm__right { flex-basis: auto !important; }
}

/* ===== Section headers (AirAlarm only) ===== */
.AirAlarm .Section__title {
  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  opacity: 0.88;
  padding-bottom: 0.375rem;
}

.AirAlarm .Section__title:after {
  content: "";
  display: block;
  margin-top: 0.375rem;
  height: 0.0625rem;
  background: linear-gradient(90deg, rgba(140,255,190,0.20), rgba(255,255,255,0.04), rgba(0,0,0,0.0));
  opacity: 0.9;
}

/* ===== Device body ===== */
.AirAlarm__device {
  position: relative;
  height: 100%;
  padding: 0.625rem;
  border-radius: 0.75rem;

  background: var(--ind-surface-device);

  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.07),
    inset 0 0 4.375rem rgba(0,0,0,0.55),
    0 0.875rem 2.375rem rgba(0,0,0,0.55);

  overflow: hidden;
}

.AirAlarm__device::after {
  content: "";
  position: absolute;
  inset: 0;
  pointer-events: none;
  background:
    repeating-linear-gradient(
      0deg,
      rgba(255,255,255,0.02) 0,
      rgba(255,255,255,0.02) 0.0625rem,
      rgba(0,0,0,0) 0.125rem,
      rgba(0,0,0,0) 0.375rem
    ),
    repeating-linear-gradient(
      90deg,
      rgba(0,0,0,0.02) 0,
      rgba(0,0,0,0.02) 0.0625rem,
      rgba(0,0,0,0) 0.125rem,
      rgba(0,0,0,0) 0.4375rem
    );
  opacity: 0.18;
  mix-blend-mode: overlay;
}

/* screws */
.AirAlarm__screw {
  position: absolute;
  width: 0.875rem;
  height: 0.875rem;
  border-radius: 50%;
  background:
    radial-gradient(circle at 35% 35%, rgba(255,255,255,0.40), rgba(255,255,255,0.05) 44%, rgba(0,0,0,0.45) 72%),
    linear-gradient(180deg, rgba(130,130,130,0.30), rgba(20,20,20,0.35));
  box-shadow: inset 0 0 0 0.0625rem rgba(0,0,0,0.65), 0 0.125rem 0.375rem rgba(0,0,0,0.40);
  opacity: 0.9;
}
.AirAlarm__screw::after {
  content: "";
  position: absolute;
  left: 0.1875rem;
  top: 0.375rem;
  width: 0.5rem;
  height: 0.125rem;
  background: rgba(0,0,0,0.60);
  border-radius: 0.0625rem;
  opacity: 0.85;
}
.AirAlarm__screw--tl { left: 0.625rem; top: 0.625rem; }
.AirAlarm__screw--tr { right: 0.625rem; top: 0.625rem; }
.AirAlarm__screw--bl { left: 0.625rem; bottom: 0.625rem; }
.AirAlarm__screw--br { right: 0.625rem; bottom: 0.625rem; }

/* sticker */
.AirAlarm__sticker {
  position: absolute;
  left: 30rem;
  top: 0.75rem;
  width: 11.875rem;
  padding: 0.5rem 0.625rem;
  border-radius: 0.4375rem;
  background: linear-gradient(180deg, rgba(245,245,245,0.92), rgba(205,205,205,0.92));
  color: rgba(0,0,0,0.86);
  box-shadow: 0 0.625rem 1.375rem rgba(0,0,0,0.35);
  transform: rotate(-1.3deg);
  opacity: 0.92;
  z-index: 6;
}
.AirAlarm__stickerTitle {
  font-weight: 900;
  letter-spacing: 0.14em;
  font-size: 0.6875rem;
  margin-bottom: 0.375rem;
}
.AirAlarm__stickerLine {
  font-family: var(--ind-font-mono);
  font-size: 0.625rem;
  opacity: 0.85;
}

/* plate */
.AirAlarm__plate {
  position: absolute;
  right: 2rem;
  top: 0.75rem;
  padding: 0.4375rem 0.75rem;
  border-radius: 0.5rem;
  background: var(--ind-surface-plate);
  border: 0.0625rem solid rgba(255,255,255,0.10);
  font-weight: 900;
  letter-spacing: 0.10em;
  font-size: 0.6875rem;
  text-transform: uppercase;
  opacity: 0.90;
  box-shadow: inset 0 0 0 0.0625rem rgba(0,0,0,0.35);
  z-index: 6;
}
.AirAlarm__plateSub {
  opacity: 0.65;
  font-weight: 800;
}
/* header layout (responsive) */
.AirAlarm__headerRow {
  display: flex;
  align-items: center;
  justify-content: space-between;
  
  margin-top: 3rem;
  padding: 0.25rem 0.5rem;
  flex-wrap: nowrap; /* desktop */
}

@media (max-width: 47.5rem) {
  .AirAlarm__headerRow {
    flex-wrap: wrap;
    justify-content: flex-start; /* чтобы не было странных пробелов */
  }

  .AirAlarm__headerLeft {
    flex: 1 1 100%;
    min-width: 0; /* важно, чтобы текст/блоки могли ужиматься */
  }

  .AirAlarm__headerRight {
    flex: 0 0 100%;
    margin-top: 0.625rem;
    margin-left: 0.625rem;
    justify-content: flex-start;
  }
}


.AirAlarm__label { letter-spacing: 0.06em; }

/* =========================================================
 * ANNUNCIATOR PANEL (aircraft-style warning lamps)
 * ========================================================= */

.AirAlarm__annunciators {
  display: inline-flex;
  gap: 0.375rem;
  align-items: center;
}

/* Базовая лампа */
.AirAlarm__ann {
  position: relative;
  min-width: 4.375rem;
  padding: 0.25rem 0.5rem;

  text-align: center;
  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  font-size: 0.75rem;

  color: rgba(0,0,0,0.75);

  border-radius: 0.375rem;

  /* тёмная рамка */
  background:
    linear-gradient(180deg, rgba(35,35,35,0.95), rgba(10,10,10,0.95));

  border: 0.0625rem solid rgba(0,0,0,0.9);

  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.04),
    inset 0 -0.125rem 0.375rem rgba(0,0,0,0.9),
    0 0.1875rem 0.5rem rgba(0,0,0,0.5);

  overflow: hidden;
}

/* Внутренний стеклянный блик */
.AirAlarm__ann::before {
  content: "";
  position: absolute;
  left: 0.125rem;
  right: 0.125rem;
  top: 0.125rem;
  height: 45%;
  border-radius: 0.25rem;

  background: linear-gradient(
    180deg,
    rgba(255,255,255,0.20),
    rgba(255,255,255,0.02)
  );

  opacity: 0.15;
  pointer-events: none;
}

/* === ON STATE === */
.AirAlarm__ann--on {
  color: rgba(0,0,0,0.9);
}

/* FIRE — красная */
.AirAlarm__ann--fire {
  background:
    radial-gradient(6.25rem 3.125rem at 50% 30%, rgba(255,80,80,0.95), rgba(180,0,0,0.95)),
    linear-gradient(180deg, rgba(255,50,50,0.95), rgba(130,0,0,0.95));

  box-shadow:
    inset 0 0 0.5rem rgba(255,0,0,0.8),
    0 0 0.875rem rgba(255,0,0,0.55),
    0 0.1875rem 0.5rem rgba(0,0,0,0.6);

  color: rgba(0,0,0,0.85);
}

/* ATMOS — янтарная */
.AirAlarm__ann--atmos {
  background:
    radial-gradient(6.25rem 3.125rem at 50% 30%, rgba(255,200,80,0.95), rgba(180,120,0,0.95)),
    linear-gradient(180deg, rgba(255,190,60,0.95), rgba(150,90,0,0.95));

  box-shadow:
    inset 0 0 0.5rem rgba(255,180,0,0.8),
    0 0 0.75rem rgba(255,180,0,0.45),
    0 0.1875rem 0.5rem rgba(0,0,0,0.6);

  color: rgba(0,0,0,0.85);
}
/* OFF state — именно затемнение, без изменения прозрачности */
.AirAlarm__ann:not(.AirAlarm__ann--on) {
  filter: brightness(0.55) saturate(0.75) contrast(1.05);
}

/* =========================================================
 * MASTER STATUS (aircraft-style annunciator)
 * ========================================================= */

.AirAlarm__status {
  margin-left: 0.625rem;
  position: relative;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;

  padding: 0.25rem 0.5rem;
  min-width: 10rem;

  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  font-size: 0.75rem;

  border-radius: 0.375rem;

  background:
    linear-gradient(180deg, rgba(35,35,35,0.95), rgba(10,10,10,0.95));

  border: 0.0625rem solid rgba(0,0,0,0.9);

  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.04),
    inset 0 -0.125rem 0.375rem rgba(0,0,0,0.9),
    0 0.1875rem 0.5rem rgba(0,0,0,0.5);

  overflow: hidden;
}

/* стеклянный блик */
.AirAlarm__status::before {
  content: "";
  position: absolute;
  left: 0.125rem;
  right: 0.125rem;
  top: 0.125rem;
  height: 45%;
  border-radius: 0.25rem;

  background: linear-gradient(
    180deg,
    rgba(255,255,255,0.18),
    rgba(255,255,255,0.02)
  );

  opacity: 0.15;
  pointer-events: none;
}

/* маленький мастер-индикатор */
.AirAlarm__statusDot {
  width: 0.625rem;
  height: 0.625rem;
  border-radius: 50%;

  background: rgba(60,60,60,0.8);

  box-shadow:
    inset 0 0 0.25rem rgba(0,0,0,0.9),
    0 0 0.125rem rgba(0,0,0,0.6);
}

/* текст */
.AirAlarm__statusText {
  color: rgba(180,180,180,0.8);
}

.AirAlarm__statusValue {
  margin-left: 0.25rem;
  font-weight: 900;
}

/* =========================
 * STATE COLORS
 * ========================= */

/* SAFE / NORMAL */
.AirAlarm__status--safe .AirAlarm__statusDot {
  background: radial-gradient(circle, rgba(80,255,150,0.9), rgba(0,120,60,0.9));
  box-shadow:
    inset 0 0 0.375rem rgba(0,255,120,0.8),
    0 0 0.5rem rgba(0,255,120,0.4);
}

.AirAlarm__status--safe .AirAlarm__statusValue {
  color: rgba(120,255,180,0.9);
}

/* WARNING */
.AirAlarm__status--warning .AirAlarm__statusDot {
  background: radial-gradient(circle, rgba(255,200,80,0.95), rgba(180,120,0,0.95));
  box-shadow:
    inset 0 0 0.375rem rgba(255,180,0,0.9),
    0 0 0.625rem rgba(255,180,0,0.45);
}

.AirAlarm__status--warning .AirAlarm__statusValue {
  color: rgba(255,210,120,0.95);
}

/* DANGER */
.AirAlarm__status--danger .AirAlarm__statusDot {
  background: radial-gradient(circle, rgba(255,80,80,0.95), rgba(180,0,0,0.95));
  box-shadow:
    inset 0 0 0.5rem rgba(255,0,0,0.9),
    0 0 0.875rem rgba(255,0,0,0.6);
}

.AirAlarm__status--danger .AirAlarm__statusValue {
  color: rgba(255,120,120,0.95);
}

/* OFF/UNKNOWN */
.AirAlarm__status--unknown {
  opacity: 0.4;
}


/* key */
.AirAlarm__key {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.5rem;
  border-radius: 0.5rem;
  background: linear-gradient(180deg, rgba(65,65,65,0.55), rgba(20,20,20,0.65));
  border: 0.0625rem solid rgba(255,255,255,0.08);
  box-shadow: inset 0 0 0 0.0625rem rgba(0,0,0,0.35);
  text-transform: uppercase;
  letter-spacing: 0.10em;
}
.AirAlarm__keyLabel { opacity: 0.75; font-weight: 900; font-size: 0.75rem; }
.AirAlarm__keyState { font-weight: 900; font-size: 0.75rem; }
.AirAlarm__key--locked .AirAlarm__keyState { color: var(--ind-bad); }
.AirAlarm__key--unlocked .AirAlarm__keyState { color: var(--ind-good); }
/* =========================
 * RCON (label + segmented buttons)
 * ========================= */

/* Метка "RCON:" с иконкой слева */
.AirAlarm__rconLabel {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;

  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;

  color: rgba(235,235,235,0.92);
  opacity: 0.92;
}

/* Контейнер кнопок */
.AirAlarm__rconGroup {
  display: inline-flex;
  align-items: center;
  gap: 0; /* сегменты без промежутков */
}

/* RCON buttons */
.AirAlarm__rconBtn {
  font-weight: 900;
  letter-spacing: 0.06em;
  text-transform: uppercase;

  /* визуально одинаковая высота/пэддинги */
  padding: 0.375rem 0.75rem !important;
  min-height: 1.875rem;

  background:
    radial-gradient(8.75rem 2.5rem at 30% 20%, rgba(255,255,255,0.10), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(70,70,70,0.55), rgba(10,10,10,0.75)) !important;

  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.12),
    inset 0 -0.875rem 1.375rem rgba(0,0,0,0.45),
    0 0.625rem 1.125rem rgba(0,0,0,0.36) !important;

  transition: transform 120ms ease, filter 120ms ease, box-shadow 120ms ease;
}


/* разделители между сегментами */
.AirAlarm__rconBtn + .AirAlarm__rconBtn {
  box-shadow:
    inset 0.0625rem 0 0 rgba(255,255,255,0.06),
    inset 0 0.0625rem 0 rgba(255,255,255,0.12),
    inset 0 -0.875rem 1.375rem rgba(0,0,0,0.45),
    0 0.625rem 1.125rem rgba(0,0,0,0.36) !important;
}

.AirAlarm__rconBtn:hover {
  filter: brightness(1.06);
  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.14),
    inset 0 -1rem 1.5rem rgba(0,0,0,0.48),
    0 0.75rem 1.375rem rgba(0,0,0,0.42) !important;
}

.AirAlarm__rconBtn:active {
  transform: translateY(0.0625rem);
  filter: brightness(0.98);
}

/* Selected states (цветной “индикатор” внутри) */
.AirAlarm__rconBtn--auto.Button--selected {
  border-radius: 0 !important;
  border-left: 0 !important;
  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.22),
    inset 0 0 1.125rem rgba(110,255,160,0.18),
    inset 0 -1rem 1.625rem rgba(0,0,0,0.52),
    0 0.75rem 1.5rem rgba(0,0,0,0.44) !important;
}

.AirAlarm__rconBtn--yes.Button--selected {
  border-radius: 0 !important;
  border-left: 0 !important;
  box-shadow:
    inset 0 0 0 0.0625rem rgba(120,200,255,0.22),
    inset 0 0 1.125rem rgba(120,200,255,0.16),
    inset 0 -1rem 1.625rem rgba(0,0,0,0.52),
    0 0.75rem 1.5rem rgba(0,0,0,0.44) !important;
}

.AirAlarm__rconBtn--no.Button--selected {
  border-radius: 0 !important;
  border-left: 0 !important;
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,140,140,0.22),
    inset 0 0 1.125rem rgba(255,140,140,0.12),
    inset 0 -1rem 1.625rem rgba(0,0,0,0.52),
    0 0.75rem 1.5rem rgba(0,0,0,0.44) !important;
}


/* ===== Pane switch (narrow) ===== */
.AirAlarm__paneSwitch { border-radius: 0.75rem; }
/* =========================================================
 * AirAlarm: move away from CRT -> plate surfaces
 * File: tgui/interfaces/AirAlarm/AirAlarm.scss
 * ======================================================= */

/* CRT bezel теперь просто контейнер/паддинг, материал задаём через ind-plate классами */
.AirAlarm__crtBezel {
  padding: 0.625rem;
  border-radius: 0.875rem;
}

/* Сам “экран” больше не CRT — просто секция на пластине */
.AirAlarm__crt {
  border-radius: 0.75rem;
  overflow: hidden;
}

/* misc */
.AirAlarm__mono {
  font-family: var(--ind-font-mono);
  letter-spacing: 0.03em;
}
.AirAlarm__hint { opacity: 0.70; font-size: 0.75rem; }

/* ===== SegDisplay (AirAlarm-specific version) ===== */
.AirAlarm__seg {
  --seg-on: var(--ind-seg-on);
  --seg-glow: var(--ind-seg-glow);
  --seg-off: var(--ind-seg-off);

  border-radius: 0.625rem;
  padding: 0.625rem 0.625rem 0.5rem 0.625rem;

  background:
    radial-gradient(31.25rem 7.5rem at 30% 0%, rgba(255,255,255,0.05), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(8,12,10,0.92), rgba(2,5,4,0.96));

  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.14),
    inset 0 0 1.875rem rgba(0,0,0,0.65);
}

.AirAlarm__seg--sm {
  padding: 0.5rem 0.5rem 0.375rem 0.5rem;
  border-radius: 0.5625rem;
}

.AirAlarm__segLabel {
  text-transform: uppercase;
  letter-spacing: 0.14em;
  font-weight: 900;
  font-size: 0.6875rem;
  opacity: 0.78;
  margin-bottom: 0.375rem;
}
.AirAlarm__seg--sm .AirAlarm__segLabel { font-size: 0.625rem; margin-bottom: 0.25rem; }

.AirAlarm__segBody {
  border-radius: 0.5rem;
  padding: 0.5rem 0.5rem 0.375rem 0.5rem;
  background: rgba(0,0,0,0.25);
  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.10),
    inset 0 0 1.25rem rgba(0,0,0,0.65);
}

.AirAlarm__segUnit {
  margin-top: 0.125rem;
  font-weight: 900;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  opacity: 0.65;
  font-size: 0.6875rem;
}
.AirAlarm__seg--sm .AirAlarm__segUnit { font-size: 0.625rem; }

/* base tint themes */
.AirAlarm__seg--c-green { --seg-on: var(--ind-seg-on-green); --seg-glow: var(--ind-seg-glow-green); --seg-off: var(--ind-seg-off-green); }
.AirAlarm__seg--c-cyan  { --seg-on: var(--ind-seg-on-cyan);  --seg-glow: var(--ind-seg-glow-cyan);  --seg-off: var(--ind-seg-off-cyan); }
.AirAlarm__seg--c-amber { --seg-on: var(--ind-seg-on-amber); --seg-glow: var(--ind-seg-glow-amber); --seg-off: var(--ind-seg-off-amber); }
.AirAlarm__seg--c-red   { --seg-on: var(--ind-seg-on-red);   --seg-glow: var(--ind-seg-glow-red);   --seg-off: var(--ind-seg-off-red); }
.AirAlarm__seg--c-white { --seg-on: var(--ind-seg-on-white); --seg-glow: var(--ind-seg-glow-white); --seg-off: var(--ind-seg-off-white); }

/* tone overlays: danger must be readable */
.AirAlarm__seg--average { filter: saturate(1.10) brightness(1.02); }
.AirAlarm__seg--bad { filter: saturate(1.20) brightness(1.03); }

/* digits */
.AirAlarm__segDigits { align-items: center; }

.AirAlarm__digit {
  position: relative;
  width: 1.5rem;
  height: 2.75rem;
  margin-right: 0.125rem;
  opacity: 0.95;
}

/* ===== Small seg display: proportional segments ===== */
.AirAlarm__seg--sm .AirAlarm__digit {
  width: 1.125rem;
  height: 2rem;
  margin-right: 0.0625rem;
}

.AirAlarm__seg--sm .AirAlarm__segment--a { top: 0.0625rem; left: 0.25rem; width: 0.625rem; height: 0.1875rem; }
.AirAlarm__seg--sm .AirAlarm__segment--b { top: 0.25rem; right: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.AirAlarm__seg--sm .AirAlarm__segment--c { bottom: 0.25rem; right: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.AirAlarm__seg--sm .AirAlarm__segment--d { bottom: 0.0625rem; left: 0.25rem; width: 0.625rem; height: 0.1875rem; }
.AirAlarm__seg--sm .AirAlarm__segment--e { bottom: 0.25rem; left: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.AirAlarm__seg--sm .AirAlarm__segment--f { top: 0.25rem; left: 0.0625rem; width: 0.1875rem; height: 0.75rem; }
.AirAlarm__seg--sm .AirAlarm__segment--g { top: 0.875rem; left: 0.25rem; width: 0.625rem; height: 0.1875rem; }

.AirAlarm__segment {
  position: absolute;
  background: var(--seg-off);
  border-radius: 0.125rem;
  transition: opacity 0.08s linear, box-shadow 0.08s linear, background 0.08s linear;
  opacity: 0.35;
}
.AirAlarm__segment::before {
  content: "";
  position: absolute;
  inset: 0;
  clip-path: polygon(10% 0%, 90% 0%, 100% 50%, 90% 100%, 10% 100%, 0% 50%);
}
.AirAlarm__segment--on {
  opacity: 1;
  background: var(--seg-on);
  box-shadow:
    0 0 0.375rem var(--seg-glow),
    0 0 1rem rgba(0,0,0,0.00);
}

.AirAlarm__segment--a { top: 0.125rem; left: 0.375rem; width: 0.875rem; height: 0.25rem; }
.AirAlarm__segment--b { top: 0.375rem; right: 0.125rem; width: 0.25rem; height: 1rem; }
.AirAlarm__segment--c { bottom: 0.375rem; right: 0.125rem; width: 0.25rem; height: 1rem; }
.AirAlarm__segment--d { bottom: 0.125rem; left: 0.375rem; width: 0.875rem; height: 0.25rem; }
.AirAlarm__segment--e { bottom: 0.375rem; left: 0.125rem; width: 0.25rem; height: 1rem; }
.AirAlarm__segment--f { top: 0.375rem; left: 0.125rem; width: 0.25rem; height: 1rem; }
.AirAlarm__segment--g { top: 1.25rem; left: 0.375rem; width: 0.875rem; height: 0.25rem; }
.AirAlarm__segment--dp { right: 0.0625rem; bottom: 0.125rem; width: 0.3125rem; height: 0.3125rem; border-radius: 50%; clip-path: none; }

@keyframes aalarmSegFlicker {
  0%   { filter: brightness(1); }
  25%  { filter: brightness(1.08); }
  35%  { filter: brightness(0.95); }
  55%  { filter: brightness(1.10); }
  100% { filter: brightness(1); }
}
.AirAlarm__seg--pulse .AirAlarm__segment--on {
  animation: aalarmSegFlicker 0.45s linear infinite;
}

/* ===== FlatGauge ===== */
.AirAlarm__flatGauge {
  padding: 0.5rem 0.625rem 0.625rem;
  border-radius: 0.75rem;
  background: linear-gradient(180deg, rgba(10,18,12,0.40), rgba(0,0,0,0.35));
  box-shadow: inset 0 0 0 0.0625rem rgba(140,255,190,0.10), inset 0 0 1.875rem rgba(0,0,0,0.55);
}
.AirAlarm__flatGaugeHead { margin-bottom: 0.5rem; }
.AirAlarm__flatGaugeTitle {
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  opacity: 0.85;
  font-size: 0.6875rem;
}
.AirAlarm__flatGaugeReadout {
  font-family: var(--ind-font-mono);
  font-weight: 900;
  letter-spacing: 0.06em;
  padding: 0.125rem 0.5rem;
  border-radius: 0.4375rem;
  background: rgba(0,0,0,0.35);
  border: 0.0625rem solid rgba(255,255,255,0.06);
  box-shadow: inset 0 0 0 0.0625rem rgba(0,0,0,0.35);
}
.AirAlarm__flatGaugeReadout--good { color: var(--ind-good); }
.AirAlarm__flatGaugeReadout--average { color: var(--ind-warn); }
.AirAlarm__flatGaugeReadout--bad { color: var(--ind-bad); }
.AirAlarm__flatGaugeUnit { opacity: 0.75; font-weight: 800; }

.AirAlarm__flatGaugeTrack {
  position: relative;
  height: 1rem;
  border-radius: 0.625rem;
  overflow: hidden;
  background: linear-gradient(180deg, rgba(70,70,70,0.26), rgba(10,10,10,0.40));
  box-shadow:
    inset 0 0 0.75rem rgba(0,0,0,0.70),
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06);
}

.AirAlarm__flatGaugeZone {
  position: absolute;
  top: 0;
  bottom: 0;
  opacity: 0.95;
  filter: saturate(1.05);
}
/* SAFE */
.FlatGauge__zone--z0 { background: rgba(110,255,160,0.35); }

/* WARN */
.FlatGauge__zone--z3 { background: rgba(240,160,60,0.30); }

/* DANGER */
.FlatGauge__zone--z5 { background: rgba(255,70,70,0.32); }

.FlatGauge__zone--z1 { background: rgba(70,180,120,0.28); }
.FlatGauge__zone--z2 { background: rgba(210,200,80,0.30); }
.FlatGauge__zone--z4 { background: rgba(255,120,90,0.30); }


.AirAlarm__flatGaugeTicks {
  position: absolute;
  inset: 0;
  background:
    repeating-linear-gradient(90deg,
      rgba(0,0,0,0.00) 0,
      rgba(0,0,0,0.00) 1rem,
      rgba(255,255,255,0.09) 1.0625rem);
  opacity: 0.35;
  mix-blend-mode: overlay;
}
.AirAlarm__flatGaugeGloss {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(255,255,255,0.18), rgba(255,255,255,0.00) 55%);
  opacity: 0.22;
}

.AirAlarm__flatGaugeNeedleWrap {
  position: absolute;
  top: 50%;
  height: 0;
  width: 0;
  transform: translate(-50%, -50%);
  pointer-events: none;
}

.AirAlarm__flatGaugeNeedle {
  position: absolute;
  left: 0;
  top: 0;
  transform: translate(-50%, -50%);
  width: 0;
  height: 0;
  border-left: 0.375rem solid transparent;
  border-right: 0.375rem solid transparent;
  border-top: 0.5625rem solid var(--ind-fg);
  filter: drop-shadow(0 0.1875rem 0.375rem rgba(0,0,0,0.60));
  opacity: 0.95;
}

/* ===== Gas grid ===== */
.AirAlarm__gasGrid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.5rem;
}
.AirAlarm__gasGrid .AirAlarm__seg--sm { min-width: 0; }
.AirAlarm__gasGrid .AirAlarm__seg--sm .AirAlarm__segBody { padding: 0.375rem 0.375rem 0.25rem 0.375rem; }
.AirAlarm__gasGrid .AirAlarm__seg--sm .AirAlarm__segLabel { letter-spacing: 0.10em; }

/* ===== Thermostat slider (car-style, Slider-based) ===== */
.AirAlarm__thermoSlider {
  flex: 1 1 auto;
  min-width: 16.25rem;
}

/* Slider == ProgressBar root */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar {
  --thermo-pct: 1%;

  position: relative;
  height: 1.875rem;
  border-radius: 0.875rem;
  overflow: visible; /* важно: чтобы инпут мог вылезать и быть кликабельным */

  /* УБИВАЕМ всё дефолтное у ProgressBar */
  background: transparent !important;
  box-shadow: none !important;
  border: 0 !important;
  outline: 0 !important;

  cursor: pointer;
  user-select: none;
}

/* ===== Верхняя цветная шкала (всегда на всю длину) ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar::before {
  content: "";
  position: absolute;
  left: 0.625rem;
  right: 0.625rem;
  top: 0.375rem;
  height: 0.5rem;
  border-radius: 0.375rem;
  pointer-events: none;
  z-index: 1;

  background:
    var(--ind-thermo-zones),
    repeating-linear-gradient(
      90deg,
      rgba(0,0,0,0.00) 0,
      rgba(0,0,0,0.00) 1.625rem,
      rgba(0,0,0,0.85) 1.6875rem,
      rgba(0,0,0,0.85) 1.8125rem
    );

  opacity: 0.95;
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.10),
    0 0 0.75rem rgba(0,0,0,0.40);
}

/* ===== Нижний “трек” (как в машине), без DOM-элемента ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar::after {
  content: "";
  position: absolute;
  left: 0.625rem;
  right: 0.625rem;
  bottom: 0.125rem;
  height: 0.625rem;
  border-radius: 0.5rem;
  pointer-events: none;
  z-index: 0;

  background: linear-gradient(180deg, rgba(35,35,35,0.55), rgba(10,10,10,0.86));
  box-shadow:
    inset 0 0.625rem 1.125rem rgba(0,0,0,0.55),
    inset 0 -0.625rem 1rem rgba(0,0,0,0.70),
    0 0.375rem 0.75rem rgba(0,0,0,0.30);
}

/* ===== Убираем “первый fill” (preview) чтобы не было двоения слоёв ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .ProgressBar__fill.ProgressBar__fill--animated {
  display: none !important;
}

/* ===== Активный fill (второй .ProgressBar__fill) ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .ProgressBar__fill {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;

  background: none !important;
  box-shadow: none !important;
  border-radius: 0 !important;

  z-index: 2; /* выше базы, ниже thumb */
}

/* Активная часть верхней шкалы до текущего значения:
   градиент должен совпасть 1:1 с фоном => background-size компенсацией */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .ProgressBar__fill::before {
  content: "";
  position: absolute;
  left: 0.625rem;
  right: 0;
  top: 0.375rem;
  height: 0.5rem;
  border-radius: 0.375rem;
  pointer-events: none;

  background:
    var(--ind-thermo-zones),
    repeating-linear-gradient(
      90deg,
      rgba(0,0,0,0.00) 0,
      rgba(0,0,0,0.00) 1.625rem,
      rgba(0,0,0,0.85) 1.6875rem,
      rgba(0,0,0,0.85) 1.8125rem
    );

  background-repeat: no-repeat;
  background-position: left top;
  /* Ключ: “растянуть” фон, чтобы при сжатии fill градиент не “съезжал” */
  background-size: calc(100% * 100 / var(--thermo-pct)) 100%;

  filter: brightness(1.35) saturate(1.15);
  box-shadow:
    0 0 0.875rem rgba(140,220,255,0.14),
    inset 0 0 0 0.0625rem rgba(255,255,255,0.12);
}

/* Лёгкая подсветка нижнего трека до текущего значения */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .ProgressBar__fill::after {
  content: "";
  position: absolute;
  left: 0.625rem;
  right: 0;
  bottom: 0.375rem;
  height: 0.625rem;
  border-radius: 0.5rem;
  pointer-events: none;

  background: linear-gradient(
    180deg,
    rgba(140,220,255,0.10),
    rgba(0,0,0,0.00) 60%,
    rgba(0,0,0,0.30)
  );
  opacity: 0.70;
}

/* ===== Текст (не мешает кликам), но ниже инпута ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .ProgressBar__content {
  position: relative;
  z-index: 5;
  pointer-events: none;
}

/* ===== Thumb ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .Slider__cursorOffset {
  position: absolute;
  min-width: 1.125rem;
  z-index: 6;
  pointer-events: none;
}

/* ===== Thumb (rectangular, car-style, 3D) ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .Slider__cursor {
  top: 60% !important;
  right: 0 !important;
  bottom: auto !important;

  width: 1.125rem !important;
  height: 2rem !important;
  transform: translate(0, -50%) !important;

  border-left: 0 !important;

  /* Закругление только сверху и снизу мягкое */
  border-radius: 0.375rem 0.375rem 0.5rem 0.5rem !important;

  /* 3D корпус */
  background:
    linear-gradient(
      180deg,
      rgba(255,255,255,0.95) 0%,
      rgba(210,210,210,0.95) 25%,
      rgba(70,70,70,0.95) 70%,
      rgba(30,30,30,1) 100%
    ) !important;

  box-shadow:
    0 0.5rem 0.875rem rgba(0,0,0,0.55),              /* внешняя тень */
    inset 0 0.0625rem 0 rgba(255,255,255,0.6),     /* верхний блик */
    inset 0 -0.25rem 0.375rem rgba(0,0,0,0.6),        /* нижняя глубина */
    inset 0 0 0 0.0625rem rgba(0,0,0,0.45) !important;
}


.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .Slider__cursor::after {
  content: "";
  position: absolute;
  left: 50%;
  top: 0.4375rem;
  bottom: 0.4375rem;
  width: 0.1875rem;
  transform: translateX(-50%);
  border-radius: 0.125rem;

  background: linear-gradient(
    180deg,
    rgba(255,255,255,0.9),
    rgba(150,150,150,0.6),
    rgba(40,40,40,0.9)
  );

  box-shadow:
    inset 0 0.0625rem 0.125rem rgba(0,0,0,0.6),
    0 0 0.375rem rgba(140,220,255,0.12);
}


.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .Slider__pointer {
  display: none !important;
}

/* ===== ВАЖНО: инпут должен быть поверх всего и кликабельным ===== */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .NumberInput {
  position: relative;
  z-index: 50 !important;
  pointer-events: auto !important;
}

/* иногда мешает внутренний input/контент */
.AirAlarm .AirAlarm__thermoSlider .Slider.ProgressBar .NumberInput__input {
  position: relative;
  z-index: 51 !important;
  pointer-events: auto !important;
}

.AirAlarm__thermoSlider--disabled {
  opacity: 0.45;
  filter: grayscale(0.55);
}
.AirAlarm__thermoRow {
  position: relative;
  z-index: 30;
}

/* ===== Rocker switch (2-pos) ===== */
.AirAlarm__switchRow { gap: 0.75rem; }
.AirAlarm__switchLabel {
  font-weight: 900;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  opacity: 0.92;
  font-size: 0.6875rem;
}

.AirAlarm__rocker {
  position: relative;
  width: 10.625rem;
  height: 2.25rem;
  border-radius: 0.75rem;

  background: var(--ind-rocker-surface);

  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.16),
    inset 0 -1.125rem 1.625rem rgba(0,0,0,0.52),
    inset 0 0 0 0.0625rem rgba(255,255,255,0.08),
    0 0.625rem 1.125rem rgba(0,0,0,0.40);

  overflow: hidden;
  user-select: none;
}

.AirAlarm__rockerRail {
  position: absolute;
  inset: 0.4375rem 0.4375rem;
  border-radius: 0.625rem;
  background:
    linear-gradient(180deg, rgba(0,0,0,0.55), rgba(255,255,255,0.03));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    inset 0 0 1.125rem rgba(0,0,0,0.70);
}

.AirAlarm__rockerHandle {
  position: absolute;
  top: 0.4375rem;
  bottom: 0.4375rem;
  width: 3.25rem;
  left: 0.4375rem;
  border-radius: 0.625rem;

  background:
    radial-gradient(circle at 28% 28%, rgba(255,255,255,0.92), rgba(185,185,185,0.52) 56%, rgba(18,18,18,0.75) 100%),
    linear-gradient(180deg, rgba(255,255,255,0.10), rgba(0,0,0,0.25));

  box-shadow:
    0 0.625rem 0.875rem rgba(0,0,0,0.55),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.42),
    inset 0 0.625rem 0.875rem rgba(255,255,255,0.06);

  transition: transform 160ms cubic-bezier(.2,.9,.2,1.1), filter 120ms ease;
  will-change: transform;
}

/* Labels: 2 cells (ON / OFF) */
.AirAlarm__rockerLabels--2 {
  position: absolute;
  inset: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  text-align: center;
  font-weight: 900;
  letter-spacing: 0.10em;
  font-size: 0.6875rem;
  text-transform: uppercase;
  opacity: 0.92;
  pointer-events: none;
}

.AirAlarm__rockerLab { opacity: 0.72; }
.AirAlarm__rocker--on  .AirAlarm__rockerLab--on  { opacity: 1; color: var(--ind-good); }
.AirAlarm__rocker--on  .AirAlarm__rockerLab--off { opacity: 0.55; }
.AirAlarm__rocker--off .AirAlarm__rockerLab--on  { opacity: 0.55; }
.AirAlarm__rocker--off .AirAlarm__rockerLab--off { opacity: 1; color: var(--ind-fg); }

/* Two hit zones */
.AirAlarm__rockerHit--2 {
  position: absolute;
  inset: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
}
.AirAlarm__rockerHitZone { cursor: pointer; }
.AirAlarm__rocker--disabled .AirAlarm__rockerHitZone { cursor: default; }

/* Positions */
.AirAlarm__rocker--on  .AirAlarm__rockerHandle { transform: translateX(0); }
.AirAlarm__rocker--off .AirAlarm__rockerHandle { transform: translateX(6.5rem); }

/* Danger styling: ON reads red */
.AirAlarm__rocker--danger.AirAlarm__rocker--on .AirAlarm__rockerLab--on { color: var(--ind-bad); }
.AirAlarm__rocker--disabled { opacity: 0.45; filter: grayscale(0.55); }
.AirAlarm__rocker--anim .AirAlarm__rockerHandle { filter: brightness(1.06); }

/* ===== Right panel inset ===== */
.AirAlarm__panelInset {
  padding: 0.75rem;
  border-radius: 1rem;

  background: var(--ind-surface-panelInset);

  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    inset 0 0 4.375rem rgba(0,0,0,0.68),
    0 0.875rem 1.625rem rgba(0,0,0,0.42);

  position: relative;
  overflow: hidden;
}

/* Match the "stat panel" bezel vibe for the control panel as well */
.AirAlarm__panelInset--crt {
  background:
    radial-gradient(56.25rem 32.5rem at 20% 0%, rgba(140,255,190,0.10), rgba(0,0,0,0) 55%),
    radial-gradient(56.25rem 32.5rem at 90% 110%, rgba(140,220,255,0.08), rgba(0,0,0,0) 55%),
    linear-gradient(180deg, rgba(24,24,24,0.90), rgba(6,6,6,0.94));
}

.AirAlarm__panelInset::before {
  content: "";
  position: absolute;
  inset: -0.125rem;
  pointer-events: none;
  background:
    linear-gradient(90deg, rgba(140,255,190,0.10), rgba(0,0,0,0) 35%, rgba(140,220,255,0.08) 70%, rgba(0,0,0,0)),
    repeating-linear-gradient(135deg, rgba(255,255,255,0.018) 0, rgba(255,255,255,0.018) 0.125rem, rgba(0,0,0,0) 0.375rem);
  opacity: 0.35;
  mix-blend-mode: overlay;
}

.AirAlarm__panel {
  border-radius: 0.75rem;
  box-shadow: inset 0 0 0 0.0625rem rgba(255,255,255,0.06);
}

/* ===== Control Panel wrapper to host overlay (ALL tabs) ===== */
.AirAlarm__panelContent {
  position: relative;
  min-height: 100%;
}

/* Full-cover overlay */
.AirAlarm__lockedOverlay {
  position: absolute;
  inset: 0;
  z-index: 50; /* выше табов и контента */
  border-radius: 10px; /* под вашу геометрию */
  pointer-events: auto;

  background:
    radial-gradient(520px 220px at 50% 20%, rgba(255, 90, 90, 0.20), rgba(0, 0, 0, 0.00) 60%),
    radial-gradient(900px 520px at 50% 120%, rgba(0, 0, 0, 0.72), rgba(0, 0, 0, 0.10) 55%),
    linear-gradient(180deg, rgba(10, 10, 10, 0.62), rgba(0, 0, 0, 0.72));

  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.08),
    inset 0 0 50px rgba(0, 0, 0, 0.55),
    0 14px 26px rgba(0, 0, 0, 0.35);

  backdrop-filter: blur(2px) saturate(1.05);
}

/* Scanlines / subtle glare */
.AirAlarm__lockedOverlay::before {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: inherit;
  pointer-events: none;
  opacity: 0.55;

  background:
    repeating-linear-gradient(
      180deg,
      rgba(255, 255, 255, 0.06) 0px,
      rgba(255, 255, 255, 0.00) 2px,
      rgba(0, 0, 0, 0.18) 4px
    ),
    radial-gradient(700px 260px at 50% 35%, rgba(255, 255, 255, 0.06), rgba(0, 0, 0, 0.00) 70%);
}

/* Centered label */
.AirAlarm__lockedOverlayInner {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  gap: 6px;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 18px;
}

.AirAlarm__lockedTitle {
  font-weight: 900;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-size: 14px;
  padding: 10px 14px;
  border-radius: 10px;

  background: linear-gradient(180deg, rgba(120, 20, 20, 0.55), rgba(40, 0, 0, 0.55));
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.10),
    0 10px 24px rgba(0, 0, 0, 0.45);
}

.AirAlarm__lockedHint {
  opacity: 0.85;
  font-size: 11px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}


/* Remove default separators inside TGUI components */
.AirAlarm .Section__header { border-bottom: 0 !important; }
.AirAlarm .Section__title { border-bottom: 0 !important; }
.AirAlarm .Tabs { border-bottom: 0 !important; box-shadow: none !important; }

/* Tabs look like physical tabs */
.AirAlarm__tabs,
.AirAlarm__paneSwitch .Tabs {
  background: linear-gradient(180deg, rgba(50,50,50,0.22), rgba(0,0,0,0.18));
  padding: 0.375rem;
  border-radius: 0.75rem;
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    inset 0 0 1.25rem rgba(0,0,0,0.55);
}

.AirAlarm .Tabs__tab,
.AirAlarm .Tabs .Button {
  border-radius: 0.625rem !important;
  padding: 0.5rem 0.75rem !important;
  font-weight: 900;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  background:
    radial-gradient(12.5rem 2.25rem at 30% 22%, rgba(255,255,255,0.12), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(65,65,65,0.35), rgba(8,8,8,0.55)) !important;
  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.10),
    inset 0 -0.875rem 1.25rem rgba(0,0,0,0.45),
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    0 0.5rem 0.875rem rgba(0,0,0,0.35) !important;
  opacity: 0.85;
}

.AirAlarm .Tabs__tab.Button--selected,
.AirAlarm .Tabs .Button.Button--selected {
  opacity: 1;
  filter: brightness(1.08);
  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.18),
    inset 0 0 1.125rem rgba(110,255,160,0.10),
    inset 0 -1rem 1.5rem rgba(0,0,0,0.52),
    0 0.625rem 1.125rem rgba(0,0,0,0.40) !important;
}

.AirAlarm__subpanel { border-radius: 0.75rem; }

.AirAlarm__modePanel {
  padding: 0.625rem;
  border-radius: 0.875rem;
  background: linear-gradient(180deg, rgba(0,0,0,0.25), rgba(0,0,0,0.12));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.05),
    inset 0 0 1.875rem rgba(0,0,0,0.55);
}

/* ===== Main panel: area alerts (legacy parity) ===== */
.AirAlarm__alertsPanel {
  border-radius: 0.875rem;
}

.AirAlarm__alertsRow {
  margin-top: 0.125rem;
}

.AirAlarm__alertKey {
  flex: 1 1 10rem;
  border-radius: 0.75rem !important;
  font-weight: 900;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  background:
    radial-gradient(13.75rem 2.75rem at 30% 18%, rgba(255, 255, 255, 0.14), rgba(0, 0, 0, 0) 58%),
    linear-gradient(180deg, rgba(70,70,70,0.42), rgba(10,10,10,0.68)) !important;
  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.10),
    inset 0 -1.125rem 1.625rem rgba(0,0,0,0.55),
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    0 0.625rem 1.125rem rgba(0,0,0,0.38) !important;
}

.AirAlarm__modeNow {
  opacity: 0.78;
  font-weight: 900;
  letter-spacing: 0.08em;
  margin-bottom: 0.5rem;
}
.AirAlarm__modeGrid {
  display: grid;
  gap: 0.5rem;
}

/* Layout A: 2x2 + POWER full width */
.AirAlarm__modeGrid--layoutA {
  grid-template-columns: 1fr 1fr;
  grid-template-areas:
    "filter replace"
    "cycle  fill"
    "power  power";
}

.AirAlarm__modeKey--filter { grid-area: filter; }
.AirAlarm__modeKey--replace { grid-area: replace; }
.AirAlarm__modeKey--cycle { grid-area: cycle; }
.AirAlarm__modeKey--fill { grid-area: fill; }
.AirAlarm__modeKey--power { grid-area: power; }

/* POWER: чуть ниже, плотнее и “системнее” */
.AirAlarm__modeKey--power {
  margin-top: 0.125rem;
  letter-spacing: 0.12em;
}

/* ===== Square panel buttons ===== */
.AirAlarm__btn {
  /* default glow (green) */
  --btnTextColor: rgba(190, 255, 210, 0.96);
  --btnGlow1: rgba(110, 255, 170, 0.26);
  --btnGlow2: rgba(110, 255, 170, 0.12);


  height: 2.125rem;
  min-height: 2.125rem;
  padding: 0 0.625rem;

  border-radius: 0.375rem !important;

  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.08em;

  color: rgba(255,255,255,0.90);
  text-shadow: 0 0.0625rem 0 rgba(0,0,0,0.70);

  background:
    repeating-linear-gradient(
      135deg,
      rgba(255,255,255,0.030) 0,
      rgba(255,255,255,0.030) 0.125rem,
      rgba(0,0,0,0.016) 0.125rem,
      rgba(0,0,0,0.016) 0.25rem
    ),
    linear-gradient(180deg, rgba(92,92,92,0.56), rgba(16,16,16,0.88)) !important;

  border: 0.0625rem solid rgba(0,0,0,0.90) !important;

  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.11),
    inset 0 0.0625rem 0 rgba(255,255,255,0.18),
    inset 0 -1rem 1.25rem rgba(0,0,0,0.48),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.32),
    0 0.625rem 1rem rgba(0,0,0,0.34) !important;

  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.375rem;

  position: relative; /* для glow-слоя */
  overflow: hidden;

  transition:
    transform 90ms ease,
    box-shadow 120ms ease,
    background 120ms ease,
    color 120ms ease,
    text-shadow 120ms ease;
}

/* Amber glow for POWER — работает даже если класс на родителе */
.AirAlarm__modeKey--power.AirAlarm__btn,
.AirAlarm__modeKey--power .AirAlarm__btn {
  --btnTextColor: rgba(255, 205, 120, 0.98);

--btnGlow1: rgba(255, 170, 0, 0.32);
--btnGlow2: rgba(255, 170, 0, 0.14);

}

.AirAlarm__modeKey--cycle.AirAlarm__btn,
.AirAlarm__modeKey--cycle .AirAlarm__btn {
  --btnTextColor: rgba(170, 230, 255, 0.98);

  --btnGlow1: rgba(80, 200, 255, 0.30);
  --btnGlow2: rgba(80, 200, 255, 0.14);
}
.AirAlarm__modeKey--replace.AirAlarm__btn,
.AirAlarm__modeKey--replace .AirAlarm__btn {
  --btnTextColor: rgba(210, 200, 255, 0.98);

  --btnGlow1: rgba(150, 130, 255, 0.28);
  --btnGlow2: rgba(150, 130, 255, 0.14);
}


.AirAlarm__modeKey--filter.AirAlarm__btn,
.AirAlarm__modeKey--filter .AirAlarm__btn {
--btnTextColor: rgb(255, 244, 210);

--btnGlow1: rgba(255, 238, 163, 0.14);
--btnGlow2: rgba(255, 240, 173, 0.05);

}

.AirAlarm__btn .Icon {
  opacity: 0.92;
  filter: drop-shadow(0 0.0625rem 0 rgba(0,0,0,0.6));
}

.AirAlarm__btn:hover {
  /* без filter: он убивает видимость glow в selected */
  background:
    repeating-linear-gradient(
      135deg,
      rgba(255,255,255,0.034) 0,
      rgba(255,255,255,0.034) 0.125rem,
      rgba(0,0,0,0.016) 0.125rem,
      rgba(0,0,0,0.016) 0.25rem
    ),
    linear-gradient(180deg, rgba(102,102,102,0.58), rgba(16,16,16,0.88)) !important;
}

/* Active press */
.AirAlarm__btn:active {
  transform: translateY(0.0625rem);
  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.10),
    inset 0 0.125rem 0 rgba(0,0,0,0.55),
    inset 0 -0.625rem 0.875rem rgba(0,0,0,0.78),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.45),
    0 0.3125rem 0.625rem rgba(0,0,0,0.22) !important;
}

/* ===== Selected (latched) ===== */
.AirAlarm__btn.Button--selected,
.AirAlarm__btn.Button--selected:hover {
  transform: translateY(0.0625rem);

  /* ВЖАТА: темнее материалом, а не filter'ом */
  background:
    repeating-linear-gradient(
      135deg,
      rgba(255,255,255,0.018) 0,
      rgba(255,255,255,0.018) 0.125rem,
      rgba(0,0,0,0.028) 0.125rem,
      rgba(0,0,0,0.028) 0.25rem
    ),
    linear-gradient(180deg, rgba(44,44,44,0.54), rgba(6,6,6,0.96)) !important;

  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.14),
    inset 0 0.1875rem 0 rgba(0,0,0,0.64),
    inset 0 -0.5rem 0.75rem rgba(0,0,0,0.88),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.52),
    0 0.25rem 0.5rem rgba(0,0,0,0.18) !important;

  /* ТЕКСТ + glow (теперь не гасится filter'ом) */
  color: var(--btnTextColor);
  text-shadow:
    0 0.0625rem 0 rgba(0,0,0,0.88),
    0 0 0.5rem var(--btnGlow1),
    0 0 1.125rem var(--btnGlow2);
}

/* Glow-слой под текстом — делает эффект заметным */
.AirAlarm__btn.Button--selected::before {
  content: "";
  position: absolute;
  inset: -0.75rem;
  pointer-events: none;
  opacity: 0.55;
  background:
    radial-gradient(13.75rem 4.375rem at 50% 50%, var(--btnGlow1), rgba(0,0,0,0) 62%);
  filter: blur(0.375rem);
}

/* Selected while active: deeper press only */
.AirAlarm__btn.Button--selected:active {
  transform: translateY(0.125rem);
}

/* Icon glow follows same color */
.AirAlarm__btn.Button--selected .Icon {
  opacity: 1;
  filter:
    drop-shadow(0 0.0625rem 0 rgba(0,0,0,0.85))
    drop-shadow(0 0 0.625rem var(--btnGlow1));
}

/* =========================================================
 * BIG RED (master alarm) — aligned with Button component
 * ========================================================= */

.AirAlarm__bigRed {
  margin-top: 0.625rem;
  display: flex;
  justify-content: center;

  padding: 0.625rem 0.625rem 0.5rem;
  border-radius: 0.75rem;

  background:
    radial-gradient(26.25rem 7.5rem at 50% 0%, rgba(255,60,60,0.10), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(255,255,255,0.04), rgba(0,0,0,0.16));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    inset 0 0 0 0.125rem rgba(0,0,0,0.55);
}

.AirAlarm__bigRedBtn {
  position: relative;
  overflow: hidden;

  min-width: 16.25rem;
  height: 2.875rem;
  padding: 0 1.125rem;

  border-radius: 0.5rem !important;

  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;

  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;

  color: rgba(255,255,255,0.92);
  text-shadow: 0 0.0625rem 0 rgba(0,0,0,0.75);

  background:
    repeating-linear-gradient(
      135deg,
      rgba(255,255,255,0.025) 0,
      rgba(255,255,255,0.025) 0.125rem,
      rgba(0,0,0,0.020) 0.125rem,
      rgba(0,0,0,0.020) 0.25rem
    ),
    linear-gradient(180deg, rgba(85,0,0,0.95), rgba(22,0,0,0.98)) !important;

  border: 0.0625rem solid rgba(0,0,0,0.92) !important;

  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.12),
    inset 0 0.0625rem 0 rgba(255,255,255,0.14),
    inset 0 -1.125rem 1.625rem rgba(0,0,0,0.58),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.42),
    0 0 1.375rem rgba(255, 20, 20, 0.26),
    0 0.875rem 1.375rem rgba(0,0,0,0.45),
    0 0 0 0.125rem rgba(0,0,0,0.72),
    0 0 0 0.1875rem rgba(255,255,255,0.06);
}

.AirAlarm__bigRedBtn .Icon {
  opacity: 0.98;
  filter: drop-shadow(0 0.0625rem 0 rgba(0,0,0,0.75));
}

.AirAlarm__bigRedBtn:hover {
  filter: brightness(1.06) saturate(1.05);
}

.AirAlarm__bigRedBtn:active {
  transform: translateY(0.125rem);
  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.12),
    inset 0 0.125rem 0 rgba(0,0,0,0.50),
    inset 0 -0.875rem 1.25rem rgba(0,0,0,0.70),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.48),
    0 0.625rem 1.125rem rgba(0,0,0,0.38),
    0 0 1.125rem rgba(255, 0, 0, 0.34) !important;
}

.AirAlarm__bigRedBtn.Button--disabled {
  filter: brightness(0.62) saturate(0.65) contrast(1.05);
}

/* =========================================================
 * BIG RED — SIREN MODE (selected)
 * ========================================================= */

.AirAlarm__bigRedBtn.Button--selected,
.AirAlarm__bigRedBtn.Button--selected:hover {
  filter: brightness(1.08) saturate(1.10);

  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.16),
    inset 0 0.0625rem 0 rgba(255,255,255,0.18),
    inset 0 -1.125rem 1.625rem rgba(0,0,0,0.52),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.40),
    0 0 1.75rem rgba(255, 30, 30, 0.34),
    0 0.875rem 1.375rem rgba(0,0,0,0.45) !important;

  animation:
    aalarmSirenPulse 1.2s ease-in-out infinite,
    aalarmSirenGlow  1.2s ease-in-out infinite;
}

.AirAlarm__bigRedBtn.Button--selected::after {
  content: "";
  position: absolute;
  top: -20%;
  bottom: -20%;
  left: 0;

  width: 60%;

  background: linear-gradient(
    90deg,
    rgba(255,255,255,0.00),
    rgba(255,80,80,0.35),
    rgba(255,255,255,0.00)
  );

  mix-blend-mode: screen;
  transform: translateX(-120%) skewX(-12deg);
  pointer-events: none;

  animation: aalarmSirenSweep 3.5s linear infinite;
}

.AirAlarm__bigRedBtn.Button--selected:active {
  animation: none;
}

.AirAlarm__bigRedBtn.Button--selected:active::after {
  animation: none;
}


/* devices card */
.AirAlarm__devicePanel {
  border-radius: 0.875rem;
  background:
    radial-gradient(32.5rem 7.5rem at 30% 0%, rgba(255,255,255,0.06), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(40,40,40,0.34), rgba(8,8,8,0.40));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    inset 0 0 1.875rem rgba(0,0,0,0.55),
    0 0.625rem 1.125rem rgba(0,0,0,0.30);
}

/* locked note */
.AirAlarm__lockedNote {
  margin-top: 0.625rem;
  padding: 0.625rem;
  border-radius: 0.75rem;
  background: rgba(255, 90, 90, 0.12);
  border: 0.0625rem solid rgba(255, 90, 90, 0.22);
  font-weight: 900;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  opacity: 0.95;
}

/* ===== Shield ===== */
.AirAlarm__shield { align-items: stretch; }

.AirAlarm__shieldList {
  flex: 0 0 44%;
  max-height: 23.75rem;
  max-width: 22.5rem;
  border-radius: 0.75rem;
  padding: 0.5rem;
  background: linear-gradient(180deg, rgba(10,10,10,0.42), rgba(0,0,0,0.36));
  box-shadow:
    inset 0 0 0 0.0625rem rgba(255,255,255,0.06),
    inset 0 0 1.875rem rgba(0,0,0,0.60),
    0 0.625rem 1.125rem rgba(0,0,0,0.28);
  overflow-y: scroll;

  /* Firefox */
  scrollbar-width: thin;
  scrollbar-color: #e6e6e6 transparent;

  /* WebKit */
  &::-webkit-scrollbar {
    width: 0.5rem;
  }

  /* Полностью прозрачный трек */
  &::-webkit-scrollbar-track {
    background: transparent;
  }

  /* Thumb — белый / ярко-серый */
  &::-webkit-scrollbar-thumb {
    background: #e6e6e6;
    border-radius: 0.5rem;
  }

  /* Hover эффект (опционально, но выглядит лучше) */
  &::-webkit-scrollbar-thumb:hover {
    background: #ffffff;
  }

  /* Убираем стрелки */
  &::-webkit-scrollbar-button {
    display: none;
    width: 0;
    height: 0;
  }
}

.AirAlarm__shieldRow {
  display: grid;
  grid-template-columns: 0.875rem 1fr auto;
  align-items: center;
  gap: 0.3125rem;
  padding: 0.5rem 0.625rem;
  border-radius: 0.625rem;
  margin-bottom: 0.5rem;
  cursor: pointer;

  background:
    radial-gradient(26.25rem 3.75rem at 30% 0%, rgba(255,255,255,0.05), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(60,60,60,0.18), rgba(10,10,10,0.20));
  box-shadow: inset 0 0 0 0.0625rem rgba(255,255,255,0.06);

  transition: filter 120ms ease, transform 120ms ease, box-shadow 120ms ease;
}
.AirAlarm__shieldRow:hover { filter: brightness(1.06); }
.AirAlarm__shieldRow:active { transform: translateY(0.0625rem); }

.AirAlarm__shieldRow--sel {
  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.18),
    inset 0 0 1.125rem rgba(110,255,160,0.10);
  background: linear-gradient(180deg, rgba(10,18,12,0.30), rgba(0,0,0,0.20));
}

.AirAlarm__shieldDot {
  width: 0.625rem;
  height: 0.625rem;
  border-radius: 50%;
  box-shadow: inset 0 -0.25rem 0.5rem rgba(0,0,0,0.55), 0 0 0.625rem rgba(0,0,0,0.35);
  border: 0.0625rem solid rgba(255,255,255,0.10);
}
.AirAlarm__shieldDot--on {
  background: radial-gradient(circle at 35% 35%, rgba(180,255,210,0.95), rgba(50,210,115,0.85) 55%, rgba(0,0,0,0.20));
}
.AirAlarm__shieldDot--off {
  background: radial-gradient(circle at 35% 35%, rgba(230,230,230,0.45), rgba(80,80,80,0.55) 55%, rgba(0,0,0,0.20));
  opacity: 0.75;
}

.AirAlarm__shieldName {
  font-weight: 900;
  letter-spacing: 0.04em;
  opacity: 0.92;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 0.9rem;
}
.AirAlarm__shieldMini {
  font-family: var(--ind-font-mono);
  opacity: 0.70;
  font-weight: 900;
}

.AirAlarm__shieldCard {
  flex: 1 1 auto;
  min-width: 15.625rem;
  padding-left: 0.25rem;
}

/* ===== Thresholds table (Table component) ===== */

.AirAlarm__sensorCard {
  border-radius: 0.75rem;
}

/* Таблица */
.AirAlarm__thTable {
  width: 100%;
}

/* Плотнее строки */
.AirAlarm__thTable .Table__cell {
  padding: 0.375rem 0.375rem;
  vertical-align: middle;
}

/* Колонка имени */
.AirAlarm__thNameHdr,
.AirAlarm__thNameCell {
  width: 7.5rem;
  min-width: 7.5rem;
  padding-left: 0;
  padding-right: 0.625rem;

  font-weight: 900;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  opacity: 0.9;
}

/* Header legend cells */
.AirAlarm__thHdrCell {
  text-align: left;
  padding-top: 0.25rem;
  padding-bottom: 0.5rem;
}

/* Легенда (бейджи) */
.AirAlarm__thLegend {
  display: inline-block;
  padding: 0.125rem 0.5rem;
  border-radius: 0.5625rem;
  background: rgba(0,0,0,0.22);
  border: 0.0625rem solid rgba(255,255,255,0.06);

  font-weight: 900;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  font-size: 0.6875rem;
  opacity: 0.95;
}

.AirAlarm__thLegend--c1 { color: var(--ind-good); }
.AirAlarm__thLegend--c2 { color: rgba(255,230,140,0.95); }
.AirAlarm__thLegend--c3 { color: rgba(255,160,90,0.95); }
.AirAlarm__thLegend--c4 { color: var(--ind-bad); }

/* Ячейки значений (td) */
.AirAlarm__thValCell {
  width: 3.375rem;
  min-width: 3.375rem;
  padding-left: 0;
  padding-right: 0.5rem;
}

/* Кнопка-ячейка */
.AirAlarm__thCell {
  width: 4rem;
  min-width: 3rem;
  height: 1.75rem;
  padding: 0 !important;

  border-radius: 0.5rem !important;
  display: inline-flex !important;
  align-items: center;
  justify-content: center;

  font-family: var(--ind-font-mono);
  font-weight: 900;
  font-size: 0.75rem;
  letter-spacing: 0.05em;

  background:
    linear-gradient(180deg, rgba(70,70,70,0.35), rgba(8,8,8,0.85)) !important;

  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.08),
    inset 0 -0.5rem 0.75rem rgba(0,0,0,0.55),
    0 0.25rem 0.5rem rgba(0,0,0,0.28) !important;
}

.AirAlarm__thCell--c1 { box-shadow: inset 0 0 0 0.0625rem rgba(140,255,190,0.22), inset 0 -0.5rem 0.75rem rgba(0,0,0,0.55), 0 0.25rem 0.5rem rgba(0,0,0,0.28) !important; }
.AirAlarm__thCell--c2 { box-shadow: inset 0 0 0 0.0625rem rgba(255,230,140,0.22), inset 0 -0.5rem 0.75rem rgba(0,0,0,0.55), 0 0.25rem 0.5rem rgba(0,0,0,0.28) !important; }
.AirAlarm__thCell--c3 { box-shadow: inset 0 0 0 0.0625rem rgba(255,160,90,0.22), inset 0 -0.5rem 0.75rem rgba(0,0,0,0.55), 0 0.25rem 0.5rem rgba(0,0,0,0.28) !important; }
.AirAlarm__thCell--c4 { box-shadow: inset 0 0 0 0.0625rem rgba(255,110,110,0.22), inset 0 -0.5rem 0.75rem rgba(0,0,0,0.55), 0 0.25rem 0.5rem rgba(0,0,0,0.28) !important; }

.AirAlarm__thCell--sel {
  filter: brightness(1.12) contrast(1.02);
}

/* Разделители строк — тонко и “панельно” */
.AirAlarm__thTable .Table__row {
  border-bottom: 0.0625rem solid rgba(255,255,255,0.05);
}

.AirAlarm__thTable .Table__row--header {
  border-bottom: 0.0625rem solid rgba(255,255,255,0.07);
}



/* ===== NumberInput skin (AirAlarm only) ===== */
.AirAlarm .NumberInput {
  border-radius: 0.75rem !important;
  background:
    radial-gradient(13.75rem 3.75rem at 30% 15%, rgba(255,255,255,0.10), rgba(0,0,0,0) 60%),
    linear-gradient(180deg, rgba(10,18,12,0.78), rgba(0,0,0,0.82)) !important;

  box-shadow:
    inset 0 0 0 0.0625rem rgba(140,255,190,0.14),
    inset 0 0 1.375rem rgba(0,0,0,0.70),
    0 0.625rem 1.125rem rgba(0,0,0,0.40) !important;

  overflow: hidden;
  pointer-events: auto;
}

.AirAlarm .NumberInput__content {
  font-family: var(--ind-font-mono) !important;
  font-weight: 900;
  letter-spacing: 0.10em;
  color: var(--ind-good) !important;
  text-shadow: 0 0 0.75rem rgba(110,255,160,0.16);
  pointer-events: none;
}

.AirAlarm .NumberInput__barContainer { opacity: 0.10; }

.AirAlarm .NumberInput__bar {
  background: linear-gradient(180deg, rgba(110,255,160,0.55), rgba(30,160,95,0.30)) !important;
}

.AirAlarm .NumberInput__input {
  background:
    radial-gradient(13.75rem 3.75rem at 30% 15%, rgba(255,255,255,0.08), rgba(0,0,0,0) 60%),
    rgba(0,0,0,0.86) !important;

  color: var(--ind-good) !important;
  border: 0.0625rem solid rgba(140,255,190,0.22) !important;
  border-radius: 0.75rem !important;
  outline: none !important;
  box-shadow: inset 0 0 1.125rem rgba(0,0,0,0.75);
  pointer-events: auto;
}

/* =========================================================
 * AirAlarm NumberInput (industrial)
 * ========================================================= */

/* Обёртка NumberInput — это Box с className="NumberInput ..." */
.AirAlarm__devicePanel .NumberInput {
  /* размеры */
  height: 1.75rem;
  min-height: 1.75rem;
  min-width: 3.125rem; /* соответствует width="8.75rem" */
  border-radius: 0.5rem;

  position: relative;
  overflow: hidden;

  /* читаемость */
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;

  /* материал панели */
  background:
    repeating-linear-gradient(
      135deg,
      rgba(255,255,255,0.020) 0,
      rgba(255,255,255,0.020) 0.125rem,
      rgba(0,0,0,0.020) 0.125rem,
      rgba(0,0,0,0.020) 0.25rem
    ),
    linear-gradient(180deg, rgba(62,62,62,0.52), rgba(10,10,10,0.92));

  border: 0.0625rem solid rgba(0,0,0,0.92);

  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.10),
    inset 0 0.0625rem 0 rgba(255,255,255,0.12),
    inset 0 -0.875rem 1.125rem rgba(0,0,0,0.62),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.42),
    0 0.5rem 0.875rem rgba(0,0,0,0.32);

  cursor: ns-resize; /* намекаем на drag */
  user-select: none;
}

/* Полоса (вертикальная) внутри */
.AirAlarm__devicePanel .NumberInput__barContainer {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 0.625rem;
  border-right: 0.0625rem solid rgba(255,255,255,0.08);
  background: linear-gradient(180deg, rgba(0,0,0,0.35), rgba(0,0,0,0.55));
}

.AirAlarm__devicePanel .NumberInput__bar {
  position: absolute;
  left: 0.0625rem;
  right: 0.0625rem;
  bottom: 0.0625rem;
  border-radius: 0.375rem;

  /* “ртутный столб” */
  background:
    linear-gradient(180deg, rgba(200,255,220,0.92), rgba(70,220,120,0.55));

  box-shadow:
    0 0 0.625rem rgba(120,255,180,0.14),
    inset 0 0 0 0.0625rem rgba(0,0,0,0.40);
  opacity: 0.85;
}

/* Значение (видимый текст) */
.AirAlarm__devicePanel .NumberInput__content {
  position: relative;
  z-index: 2;

  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;

  padding-left: 0.75rem;  /* место под bar */
  padding-right: 0.625rem;

  color: rgba(235,240,245,0.96);
  text-shadow:
    0 0.0625rem 0 rgba(0,0,0,0.85),
    0 0 0.625rem rgba(255,255,255,0.05);

  pointer-events: none; /* чтобы drag всегда работал */
}

/* Режим редактирования: input появляется вместо текста */
.AirAlarm__devicePanel .NumberInput__input {
  position: absolute;
  z-index: 3;

  left: 0.75rem;          /* после bar */
  right: 0.375rem;
  top: 0.25rem;
  bottom: 0.25rem;

  width: auto;
  border-radius: 0.375rem;

  border: 0.0625rem solid rgba(0,0,0,0.88);
  background: linear-gradient(180deg, rgba(10,10,10,0.72), rgba(0,0,0,0.88));

  color: rgba(255,255,255,0.98);
  font-weight: 900;
  letter-spacing: 0.10em;
  text-transform: uppercase;

  padding: 0 0.5rem;
  outline: none;

  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.10),
    inset 0 0.0625rem 0 rgba(255,255,255,0.10),
    inset 0 -0.625rem 0.875rem rgba(0,0,0,0.72);

  /* ввод */
  text-align: center;
}

/* Focus — лёгкая подсветка (не неон) */
.AirAlarm__devicePanel .NumberInput__input:focus {
  box-shadow:
    0 0 0 0.0625rem rgba(255,255,255,0.14),
    0 0 0.75rem rgba(140,255,190,0.14),
    inset 0 0.0625rem 0 rgba(255,255,255,0.12),
    inset 0 -0.625rem 0.875rem rgba(0,0,0,0.74);
}

/* Disabled */
.AirAlarm__devicePanel .NumberInput[aria-disabled="true"],
.AirAlarm__devicePanel .NumberInput.NumberInput--disabled,
.AirAlarm__devicePanel .NumberInput[disabled] {
  cursor: not-allowed;
  filter: brightness(0.72) saturate(0.70) contrast(1.05);
}

/* На hover слегка "оживает" */
.AirAlarm__devicePanel .NumberInput:hover {
  filter: brightness(1.04) contrast(1.02);
}

/* External kPa control group: reset + input <= 7.5rem */
.AirAlarm__devicePanel .AirAlarm__kpaCtl {
  width: 7.5rem;
  max-width: 7.5rem;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.25rem;
  margin-left: auto; /* убирает "сдвиг" влево внутри LabeledList */
}

.AirAlarm__devicePanel .AirAlarm__kpaInput {
  flex: 0 0 auto;
}

/* Символьный RESET */
.AirAlarm__devicePanel .AirAlarm__miniBtn--sym {
  width: 1.75rem;
  min-width: 1.75rem;
  height: 1.75rem;
  padding: 0;
  line-height: 1.75rem;
  text-align: center;

  font-weight: 900;
  letter-spacing: 0;
}


/* ===== Buttons global feel (AirAlarm scope) ===== */
.AirAlarm .Button {
  position: relative;
  overflow: hidden;

  /* keycap shine */
  &::before {
    content: "";
    position: absolute;
    inset: 0.0625rem 0.0625rem auto 0.0625rem;
    height: 46%;
    border-radius: 0.5rem;
    background: linear-gradient(180deg, rgba(255,255,255,0.18), rgba(255,255,255,0.00));
    opacity: 0.55;
    pointer-events: none;
  }

  /* bezel rim */
  &::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: 0.5625rem;
    box-shadow: inset 0 0 0 0.0625rem rgba(0,0,0,0.55), inset 0 0 0 0.125rem rgba(255,255,255,0.03);
    pointer-events: none;
  }

  border-radius: 0.5rem;
  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.12),
    inset 0 -0.875rem 1.375rem rgba(0,0,0,0.44),
    0 0.625rem 1.125rem rgba(0,0,0,0.36);
  transform: translateY(0);
  letter-spacing: 0.04em;
  transition: transform 120ms ease, filter 120ms ease, box-shadow 120ms ease;
}
.AirAlarm .Button:hover {
  filter: brightness(1.06);
  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.14),
    inset 0 -1rem 1.5rem rgba(0,0,0,0.48),
    0 0.75rem 1.375rem rgba(0,0,0,0.42);
}
.AirAlarm .Button:active {
  transform: translateY(0.0625rem);
  filter: brightness(0.98);
  box-shadow:
    inset 0 0.0625rem 0 rgba(255,255,255,0.08),
    inset 0 -0.625rem 1rem rgba(0,0,0,0.55),
    0 0.375rem 0.875rem rgba(0,0,0,0.42);
}

/* ===== Animations ===== */
@keyframes aalarmDangerPulse {
  0%   { filter: saturate(1) brightness(1); }
  50%  { filter: saturate(1.18) brightness(1.06); }
  100% { filter: saturate(1) brightness(1); }
}
.AirAlarm--dangerPulse { animation: aalarmDangerPulse 1.0s ease-in-out infinite; }

@keyframes aalarmCrtBreath {
  0%   { opacity: 0.88; }
  50%  { opacity: 1.00; }
  100% { opacity: 0.88; }
}

@keyframes aalarmCrtFlickerHard {
  0%   { opacity: 0.08; }
  2%   { opacity: 0.22; }
  3%   { opacity: 0.06; }
  6%   { opacity: 0.18; }
  9%   { opacity: 0.05; }
  14%  { opacity: 0.16; }
  100% { opacity: 0.08; }
}

@keyframes aalarmScanSweep {
  0%   { transform: translateY(-120%); opacity: 0.0; }
  10%  { opacity: 0.28; }
  35%  { opacity: 0.10; }
  100% { transform: translateY(140%); opacity: 0.0; }
}

@keyframes aalarmNoisePop {
  0% { opacity: 0.10; transform: translate(0,0); }
  20% { opacity: 0.22; transform: translate(0.0625rem,-0.0625rem); }
  40% { opacity: 0.12; transform: translate(-0.0625rem,0.0625rem); }
  60% { opacity: 0.24; transform: translate(0.0625rem,0.0625rem); }
  80% { opacity: 0.11; transform: translate(-0.0625rem,-0.0625rem); }
  100% { opacity: 0.10; transform: translate(0,0); }
}

@keyframes ann-blink {
  0%, 100% { filter: brightness(1); }
  50% { filter: brightness(1.9); }
}

.AirAlarm__ann--fire.AirAlarm__ann--on {
  animation: ann-blink 0.6s infinite ease-in-out;
}
.AirAlarm__ann--atmos.AirAlarm__ann--on {
  animation: ann-blink 0.6s infinite ease-in-out;
}

@keyframes aalarmSirenSweep {
  0%   { transform: translateX(-120%) skewX(-12deg); opacity: 0; }
  8%   { opacity: 0.85; }
  15%  { opacity: 0.45; }
  22%  { transform: translateX(120%) skewX(-12deg); opacity: 0; }
  100% { transform: translateX(120%) skewX(-12deg); opacity: 0; }
}

@keyframes aalarmSirenPulse {
  0%   { filter: brightness(1.00) saturate(1.00); }
  50%  { filter: brightness(1.18) saturate(1.18); }
  100% { filter: brightness(1.00) saturate(1.00); }
}

@keyframes aalarmSirenGlow {
  0%   { box-shadow:
          0 0 1.125rem rgba(255, 20, 20, 0.22),
          0 0.875rem 1.375rem rgba(0,0,0,0.45),
          0 0 0 0.0625rem rgba(255,255,255,0.16),
          inset 0 0.0625rem 0 rgba(255,255,255,0.18),
          inset 0 -1.125rem 1.625rem rgba(0,0,0,0.52),
          inset 0 0 0 0.0625rem rgba(0,0,0,0.40);
        }
  50%  { box-shadow:
          0 0 2.125rem rgba(255, 30, 30, 0.42),
          0 0.875rem 1.375rem rgba(0,0,0,0.45),
          0 0 0 0.0625rem rgba(255,255,255,0.20),
          inset 0 0.0625rem 0 rgba(255,255,255,0.18),
          inset 0 -1.125rem 1.625rem rgba(0,0,0,0.48),
          inset 0 0 0 0.0625rem rgba(0,0,0,0.40);
        }
  100% { box-shadow:
          0 0 1.125rem rgba(255, 20, 20, 0.22),
          0 0.875rem 1.375rem rgba(0,0,0,0.45),
          0 0 0 0.0625rem rgba(255,255,255,0.16),
          inset 0 0.0625rem 0 rgba(255,255,255,0.18),
          inset 0 -1.125rem 1.625rem rgba(0,0,0,0.52),
          inset 0 0 0 0.0625rem rgba(0,0,0,0.40);
        }
}

```

`packages\tgui\styles\interfaces\AlertModal.scss`

```scss
/**
 * Copyright (c) 2020 bobbahbrown (https://github.com/bobbahbrown)
 * SPDX-License-Identifier: MIT
 */

@use '../colors.scss';

.AlertModal__Message {
  text-align: center;
  justify-content: center;
}

.AlertModal__Buttons {
  justify-content: center;
}

.AlertModal__Loader {
  width: 100%;
  position: relative;
  height: 4px;
}

.AlertModal__LoaderProgress {
  position: absolute;
  transition: background-color 500ms ease-out, width 500ms ease-out;
  background-color: colors.bg(colors.$primary);
  height: 100%;
}

```

`packages\tgui\styles\interfaces\CharacterSetup.scss`

```scss
/* tgui/styles/interfaces/CharacterSetup.scss
 * "Nanotrasen Personnel Terminal" — sci-fi corporate character creator.
 * Holographic preview, color-coded categories, glass-morphism cards.
 */

/* =========================================================
 * ROOT & CSS CUSTOM PROPERTIES
 * ========================================================= */

.CharSetup {
  /* Category accent palette — unified blue theme */
  --cs-identity:    #5b8fc4;
  --cs-appearance:  #5b8fc4;
  --cs-hair:        #5b8fc4;
  --cs-wardrobe:    #5b8fc4;
  --cs-augments:    #5b8fc4;
  --cs-career:      #5b8fc4;
  --cs-personality: #5b8fc4;
  --cs-background:  #5b8fc4;
  --cs-settings:    #5b8fc4;

  /* Active accent */
  --cs-accent: #5b8fc4;

  /* Surface tokens */
  --cs-surface-card:        rgba(255, 255, 255, 0.05);
  --cs-surface-card-hover:  rgba(255, 255, 255, 0.08);
  --cs-surface-card-active: rgba(255, 255, 255, 0.12);
  --cs-surface-expanded:    rgba(0, 0, 0, 0.25);
  --cs-surface-sidebar:     rgba(0, 0, 0, 0.30);

  /* Border tokens */
  --cs-border-subtle:  rgba(255, 255, 255, 0.08);
  --cs-border-medium:  rgba(255, 255, 255, 0.14);
  --cs-border-glow:    rgba(255, 255, 255, 0.22);

  /* Typography */
  --cs-font-mono: ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;

  height: 100%;
}


/* =========================================================
 * LEFT PANEL — character card (preview + nav combined)
 * ========================================================= */

.CharSetup__leftPanel {
  display: flex;
  flex-direction: column;
  width: 14.5rem;
  height: 100%;

  background: rgba(28, 28, 32, 0.98);
  border: 0.0625rem solid rgba(255, 255, 255, 0.08);
  border-radius: 0.5rem;

  overflow: hidden;
}

/* Divider between preview and nav tabs */
.CharSetup__navDivider {
  height: 0.0625rem;
  margin: 0 0.75rem;
  flex-shrink: 0;

  background: linear-gradient(
    90deg,
    transparent,
    rgba(130, 145, 168, 0.20) 30%,
    rgba(130, 145, 168, 0.12) 70%,
    transparent
  );
}


/* =========================================================
 * SIDEBAR — category navigation
 * ========================================================= */

.CharSetup__sidebar {
  display: flex;
  flex-direction: column;
  gap: 0.0625rem;
  padding: 0.25rem 0.375rem;
  flex: 1;
  overflow-y: scroll;
}

.CharSetup__tab {
  position: relative;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.625rem;
  border-radius: 0.25rem;
  cursor: pointer;
  user-select: none;
  -ms-user-select: none;

  font-size: 0.8125rem;
  font-weight: 600;
  letter-spacing: 0.03em;
  color: rgba(235, 235, 235, 0.78);

  transition:
    background 120ms ease,
    color 120ms ease,
    filter 90ms ease,
    transform 90ms ease;
}

.CharSetup__tab:hover {
  background: rgba(255, 255, 255, 0.04);
  color: rgba(235, 235, 235, 0.80);
}

.CharSetup__tab:active {
  transform: translateY(0.0625rem);
}

/* Selected tab */
.CharSetup__tab--selected {
  background: rgba(255, 255, 255, 0.07);
  color: rgba(235, 235, 235, 0.98);
  font-weight: 700;
}

/* Glow left-border on selected tab */
.CharSetup__tab--selected::before {
  content: "";
  position: absolute;
  left: 0;
  top: 0.25rem;
  bottom: 0.25rem;
  width: 0.1875rem;
  border-radius: 0 0.125rem 0.125rem 0;

  background: var(--cs-tab-accent, var(--cs-identity));
}


/* Per-category accent colors */
.CharSetup__tab--identity    { --cs-tab-accent: var(--cs-identity); }
.CharSetup__tab--appearance  { --cs-tab-accent: var(--cs-appearance); }
.CharSetup__tab--hair        { --cs-tab-accent: var(--cs-hair); }
.CharSetup__tab--wardrobe    { --cs-tab-accent: var(--cs-wardrobe); }
.CharSetup__tab--augmentations { --cs-tab-accent: var(--cs-augments); }
.CharSetup__tab--career      { --cs-tab-accent: var(--cs-career); }
.CharSetup__tab--personality { --cs-tab-accent: var(--cs-personality); }
.CharSetup__tab--background  { --cs-tab-accent: var(--cs-background); }
.CharSetup__tab--settings    { --cs-tab-accent: var(--cs-settings); }

/* Tab icon */
.CharSetup__tabIcon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.25rem;
  font-size: 0.875rem;
  opacity: 0.85;
  transition: opacity 120ms ease;
}

.CharSetup__tab--selected .CharSetup__tabIcon {
  opacity: 1;
}


/* =========================================================
 * PREVIEW FRAME — holographic character display
 * ========================================================= */

.CharSetup__preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0.625rem 0.375rem 0.375rem;
  flex-shrink: 0;

  /* Radial glow behind preview */
  background: transparent;
}

.CharSetup__previewFrame {
  position: relative;
  width: 10rem;
  height: 10rem;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;

  background: rgba(0, 0, 0, 0.25);

  border: 0.0625rem solid rgba(130, 145, 168, 0.25);
  border-radius: 0.375rem;
}

.CharSetup__previewFrame .game-icon {
  image-rendering: pixelated;
  width: 10rem;
  height: 10rem;
  position: relative;
  z-index: 1;
}

.CharSetup__previewCanvas {
  image-rendering: pixelated;
  width: 100%;
  height: 100%;
  position: relative;
  z-index: 1;
}

.CharSetup__slotPickerPreviewImg {
  image-rendering: pixelated;
  width: 4rem;
  height: 4rem;
}

.CharSetup__compositorPreview {
  image-rendering: pixelated;
}

.CharSetup__gearSpriteIcon {
  image-rendering: pixelated;
  display: block;
}

/* Loading spinner placeholder */
.CharSetup__previewLoading {
  width: 10rem;
  height: 10rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 0.375rem;
}

/* Name display below preview */
.CharSetup__previewName {
  margin-top: 0.375rem;
  text-align: center;
  font-size: 0.875rem;
  font-weight: 800;
  letter-spacing: 0.06em;
  color: rgba(196, 204, 220, 0.95);
}

/* Species / gender / age meta line */
.CharSetup__previewMeta {
  text-align: center;
  font-size: 0.6875rem;
  color: rgba(170, 178, 196, 0.70);
  letter-spacing: 0.10em;
  text-transform: uppercase;
  margin-top: 0.0625rem;
  font-weight: 600;
}

/* Direction buttons row */
.CharSetup__dirControls {
  display: flex;
  gap: 0.125rem;
  margin-top: 0.3125rem;
  justify-content: center;
}

.CharSetup__dirControls .Button {
  width: 1.75rem;
  text-align: center;
}

/* Quick action + preview toggles row */
.CharSetup__actionRow {
  display: flex;
  gap: 0.125rem;
  margin-top: 0.25rem;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
}

/* Character slot selector — bottom of preview column */
/* Slot selector wrapper */
.CharSetup__slotSelectorWrap {
  margin-top: 0.5rem;
}

.CharSetup__slotSelector {
  display: flex;
  align-items: center;
  gap: 0.1875rem;
  padding: 0.3125rem 0.375rem;
  background: rgba(0, 0, 0, 0.30);
  border: 0.0625rem solid rgba(130, 145, 168, 0.10);
  border-radius: 0.25rem;
}

.CharSetup__slotName {
  flex: 1;
  min-width: 0;
  text-align: center;
  line-height: 1.2;

  &:hover .CharSetup__slotNameLabel {
    color: rgba(130, 145, 168, 0.95);
  }
}

.CharSetup__slotNameLabel {
  font-size: 0.875rem;
  font-weight: bold;
  color: rgba(210, 215, 228, 0.90);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: color 0.15s ease;
}

.CharSetup__slotNumber {
  font-size: 0.6875rem;
  color: rgba(170, 178, 200, 0.70);
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

/* Slot picker — inline expandable grid of character cards */
.CharSetup__slotPicker {
  margin-top: 0.25rem;
  padding: 0.375rem;
  max-height: 24rem;
  overflow-y: auto;

  background: rgba(0, 0, 0, 0.25);
  border: 0.0625rem solid rgba(130, 145, 168, 0.12);
  border-radius: 0.25rem;
}

.CharSetup__slotPickerGrid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.3125rem;
}

.CharSetup__slotPickerCard {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 0;
  padding: 0.375rem 0.25rem;
  border-radius: 0.25rem;
  border: 0.0625rem solid rgba(130, 145, 168, 0.08);
  background: rgba(255, 255, 255, 0.03);
  cursor: pointer;
  transition: background 0.15s ease, border-color 0.15s ease, box-shadow 0.15s ease;

  &:hover {
    background: rgba(130, 145, 168, 0.08);
    border-color: rgba(130, 145, 168, 0.25);
  }

  &--active {
    background: rgba(130, 145, 168, 0.12);
    border-color: rgba(130, 145, 168, 0.35);
  }

  &--empty {
    opacity: 0.5;
  }
}

.CharSetup__slotPickerPreview {
  width: 4rem;
  height: 4rem;
  display: flex;
  align-items: center;
  justify-content: center;
  image-rendering: pixelated;

  .game-icon {
    image-rendering: pixelated;
  }
}

.CharSetup__slotPickerName {
  margin-top: 0.25rem;
  font-size: 0.6875rem;
  font-weight: bold;
  color: rgba(210, 215, 228, 0.80);
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
}


/* =========================================================
 * CARD SYSTEM — glass-morphism containers
 * ========================================================= */

.CharSetup__card {
  padding: 0.625rem;
  background: var(--cs-surface-card);
  border-radius: 0.25rem;
  border: 0.0625rem solid var(--cs-border-subtle);

  transition:
    background 120ms ease,
    box-shadow 120ms ease,
    filter 120ms ease,
    border-color 120ms ease;
}

.CharSetup__card:hover {
}

/* Expandable card */
.CharSetup__card--expandable {
  cursor: pointer;
}

.CharSetup__card--expandable:hover {
  background: var(--cs-surface-card-hover);
}

/* Expanded state — top corners only */
.CharSetup__card--expanded {
  background: var(--cs-surface-card-active);
  border-radius: 0.25rem 0.25rem 0 0;
  border-bottom-color: transparent;
}

/* Card body — shown when expanded */
.CharSetup__cardBody {
  padding: 0.625rem;
  background: var(--cs-surface-expanded);
  border-radius: 0 0 0.25rem 0.25rem;
  border: 0.0625rem solid var(--cs-border-subtle);
  border-top: none;
}

/* Left accent border variant */
.CharSetup__card--accentLeft {
  border-left: 0.1875rem solid var(--cs-card-accent, var(--cs-accent));

  /* Subtle glow from the accent border */
}

/* Blue-tinted info card */
.CharSetup__card--info {
  background: rgba(100, 149, 237, 0.08);
  border-color: rgba(100, 149, 237, 0.18);
}

/* Green-tinted enabled card */
.CharSetup__card--enabled {
  background: rgba(80, 200, 120, 0.06);
  border-color: rgba(80, 200, 120, 0.18);
}

/* Card icon — large colored icon in header */
.CharSetup__cardIcon {
  font-size: 1.2em;
  line-height: 1;
}

/* Card text preview — truncated single line */
.CharSetup__cardPreview {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 14rem;
  font-size: 0.6875rem;
  color: rgba(235, 235, 235, 0.50);
}


/* =========================================================
 * PAPER-DOLL — character sprite with holographic frame
 * ========================================================= */

/* Character preview frame */
.CharSetup__paperDollCenter {
  position: relative;
  width: 100%;
  height: 100%;

  border: 0.0625rem solid rgba(255, 255, 255, 0.10);
  border-radius: 0.25rem;
  background: rgba(0, 0, 0, 0.25);
  overflow: hidden;
}

/* Character sprite */
.CharSetup__paperDollSprite {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  image-rendering: pixelated;
  z-index: 1;
  object-fit: contain;
}

/* =========================================================
 * WARDROBE
 * ========================================================= */

/* Equipment mode: [doll column] | [item browser] */
.CharSetup__wardrobeLayout {
  display: flex;
  gap: 0.5rem;
  height: 100%;
  min-height: 0;
}

.CharSetup__wardrobeCenter {
  flex: 0 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.375rem;
}

.CharSetup__wardrobeRight {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* Slot icon bar — 4-column grid below the doll */
.CharSetup__slotIconBar {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0.25rem;
  width: 20rem;
}

.CharSetup__slotIconBtn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.125rem;
  padding: 0.375rem 0.25rem;
  cursor: pointer;
  border-radius: 0.25rem;
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  background: rgba(255, 255, 255, 0.03);
  transition: background 90ms ease, border-color 90ms ease;

  &:hover {
    background: rgba(77, 182, 172, 0.08);
    border-color: rgba(77, 182, 172, 0.25);
  }
}

.CharSetup__slotIconBtn--active {
  background: rgba(77, 182, 172, 0.14);
  border-color: rgba(77, 182, 172, 0.55);

  &:hover {
    background: rgba(77, 182, 172, 0.19);
    border-color: rgba(77, 182, 172, 0.70);
  }
}

.CharSetup__slotIconBtn--equipped {
  border-color: rgba(80, 200, 120, 0.22);
  background: rgba(80, 200, 120, 0.05);

  &:hover {
    background: rgba(80, 200, 120, 0.10);
    border-color: rgba(80, 200, 120, 0.40);
  }
}

.CharSetup__slotIconBtn--equipped.CharSetup__slotIconBtn--active {
  background: rgba(80, 200, 120, 0.14);
  border-color: rgba(80, 200, 120, 0.55);
}

.CharSetup__slotIconBtnIcon {
  width: 2rem;
  height: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.875rem;
  opacity: 0.5;
  image-rendering: pixelated;

  .CharSetup__slotIconBtn--equipped &,
  .CharSetup__slotIconBtn--active & {
    opacity: 1;
  }
}

.CharSetup__slotIconBtnLabel {
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: rgba(170, 178, 196, 0.68);
  white-space: nowrap;

  .CharSetup__slotIconBtn--active & {
    color: rgba(77, 182, 172, 0.90);
  }

  .CharSetup__slotIconBtn--equipped & {
    color: rgba(80, 200, 120, 0.70);
  }
}

/* Underwear + backpack row below slot bar */
.CharSetup__dollUnderwear {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.25rem 0.375rem;
  width: 20rem;
}

/* Misc mode: [category list] | [item browser] */
.CharSetup__wardrobeMiscLayout {
  display: flex;
  gap: 0.5rem;
  height: 100%;
  min-height: 0;
}

.CharSetup__wardrobeMiscCats {
  flex: 0 0 9rem;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  overflow-y: auto;
}

/* MISC wide button below slot icon bar — matches slot icon button style */
.CharSetup__miscBtn {
  width: 20rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.125rem;
  padding: 0.375rem 0.25rem;
  background: var(--cs-surface-card);
  border: 0.0625rem solid var(--cs-border-subtle);
  border-radius: 0.25rem;
  cursor: pointer;
  transition: background 0.12s, border-color 0.12s;

  &:hover {
    background: rgba(77, 182, 172, 0.08);
    border-color: rgba(77, 182, 172, 0.25);
  }

  &--active {
    background: rgba(77, 182, 172, 0.14);
    border-color: rgba(77, 182, 172, 0.55);

    &:hover {
      background: rgba(77, 182, 172, 0.19);
      border-color: rgba(77, 182, 172, 0.70);
    }
  }
}

.CharSetup__miscBtnIcon {
  width: 2rem;
  height: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.875rem;
  opacity: 0.5;

  .CharSetup__miscBtn--active & {
    opacity: 1;
    color: rgba(77, 182, 172, 0.90);
  }
}

.CharSetup__miscBtnLabel {
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: rgba(170, 178, 196, 0.68);

  .CharSetup__miscBtn--active & {
    color: rgba(77, 182, 172, 0.90);
  }
}

/* Collapsible category header for misc item browser */
.CharSetup__miscCatHeader {
  display: flex;
  align-items: center;
  padding: 0.3125rem 0.625rem;
  background: rgba(255, 255, 255, 0.04);
  border-radius: 0.25rem;
  cursor: pointer;
  font-size: 0.8125rem;
  font-weight: bold;
  color: rgba(255, 255, 255, 0.65);
  margin-bottom: 0.125rem;
  user-select: none;

  &:hover {
    background: rgba(255, 255, 255, 0.07);
    color: rgba(255, 255, 255, 0.9);
  }

  &__label {
    flex: 1;
  }
}

/* ── Character doll container ── */
.CharSetup__dollContainer {
  position: relative;
  width: 20rem;
  height: 20rem;
}

/* ── Body-part highlight overlays — sprite silhouettes with teal tint ── */
.CharSetup__dollPartHighlight {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  image-rendering: pixelated;
  /* z-index 4 — above character sprite (1), scanlines (2), corner brackets (3) */
  z-index: 4;
  opacity: 0;
  transition: opacity 120ms ease;

  &--equipped {
    opacity: 0;
  }

  &--hovered {
    opacity: 0.55;
  }
}

/* Zone label — hover-only, fades when mouse leaves (driven by JS state) */
.CharSetup__dollZoneLabel {
  position: absolute;
  top: 0.25rem;
  left: 50%;
  transform: translateX(-50%);
  z-index: 20;
  pointer-events: none;

  padding: 0.1875rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  white-space: nowrap;

  background: rgba(20, 20, 24, 0.92);
  border: 0.0625rem solid rgba(77, 182, 172, 0.40);
  color: rgba(77, 182, 172, 0.90);
}

/* ── Compact slot tiles (left pane) ── */
.CharSetup__slotTile {
  display: flex;
  align-items: center;
  gap: 0.4375rem;
  padding: 0.3125rem 0.5rem;
  cursor: pointer;
  border-radius: 0.25rem;
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  background: rgba(255, 255, 255, 0.03);
  transition:
    background 90ms ease,
    border-color 90ms ease,
    box-shadow 90ms ease;

  &:hover {
    background: rgba(77, 182, 172, 0.08);
    border-color: rgba(77, 182, 172, 0.25);
  }
}

.CharSetup__slotTile--active {
  background: rgba(77, 182, 172, 0.14);
  border-color: rgba(77, 182, 172, 0.55);

  &:hover {
    background: rgba(77, 182, 172, 0.19);
    border-color: rgba(77, 182, 172, 0.70);
  }
}

.CharSetup__slotTile--equipped {
  border-color: rgba(80, 200, 120, 0.22);
  background: rgba(80, 200, 120, 0.05);

  &:hover {
    background: rgba(80, 200, 120, 0.10);
    border-color: rgba(80, 200, 120, 0.40);
  }
}

.CharSetup__slotTile--equipped.CharSetup__slotTile--active {
  background: rgba(80, 200, 120, 0.14);
  border-color: rgba(80, 200, 120, 0.55);
}

.CharSetup__slotTileIcon {
  width: 2rem;
  height: 2rem;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
  opacity: 0.45;
  image-rendering: pixelated;
}

.CharSetup__slotTile--equipped .CharSetup__slotTileIcon,
.CharSetup__slotTile--active .CharSetup__slotTileIcon {
  opacity: 1;
}

.CharSetup__slotTileText {
  min-width: 0;
  flex: 1;
  overflow: hidden;
}

/* Default: just the slot name, muted uppercase */
.CharSetup__slotTileName {
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.07em;
  text-transform: uppercase;
  color: rgba(170, 178, 196, 0.72);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.CharSetup__slotTile:hover .CharSetup__slotTileName {
  color: rgba(170, 178, 196, 0.95);
}

.CharSetup__slotTile--active .CharSetup__slotTileName {
  color: rgba(77, 182, 172, 0.90);
}

/* When equipped: tile name shows item name, no uppercase */
.CharSetup__slotTile--equipped .CharSetup__slotTileName {
  font-size: 0.6875rem;
  font-weight: 500;
  text-transform: none;
  letter-spacing: 0;
  color: rgba(80, 200, 120, 0.80);
}

/* Slot name sub-label (shown when equipped) */
.CharSetup__slotTileSlot {
  font-size: 0.6875rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(80, 200, 120, 0.45);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Right pane empty state hint */
/* ── Loadout HUD bar (teal-themed, mirrors augHud) ── */
@keyframes lpBarPulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.65; }
}

.CharSetup__loadoutHud {
  flex-shrink: 0;
  padding: 0.625rem 0.75rem;
  background: rgba(0, 0, 0, 0.20);
  border: 0.0625rem solid rgba(77, 182, 172, 0.18);
  border-radius: 0.375rem;
  margin-bottom: 0.5rem;
}

.CharSetup__loadoutHudRow {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  margin-bottom: 0.375rem;

  &:last-child {
    margin-bottom: 0;
  }
}

.CharSetup__loadoutHudLabel {
  flex-shrink: 0;
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: rgba(77, 182, 172, 0.90);
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
}

.CharSetup__lpBarWrap {
  position: relative;
  flex: 1;
  height: 1.25rem;
  background: rgba(0, 0, 0, 0.5);
  border: 0.0625rem solid rgba(77, 182, 172, 0.20);
  border-radius: 0.125rem;
  overflow: hidden;

  &--over {
    border-color: rgba(244, 67, 54, 0.40);
  }
}

.CharSetup__lpBarFill {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  background: linear-gradient(90deg, rgba(77, 182, 172, 0.60), rgba(77, 182, 172, 0.35));
  border-right: 0.125rem solid rgba(77, 182, 172, 0.85);
  transition: width 200ms ease;



  &--over {
    background: linear-gradient(90deg, rgba(244, 67, 54, 0.70), rgba(244, 67, 54, 0.45));
    border-right-color: rgba(244, 67, 54, 0.90);
  }
}

.CharSetup__lpBarText {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.875rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(255, 255, 255, 0.90);
  letter-spacing: 0.05em;
}

.CharSetup__loadoutHudSetRow {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.5rem;
}

.CharSetup__loadoutHudSetLabel {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
  color: rgba(170, 178, 196, 0.70);
  min-width: 6rem;
  text-align: center;
}

/* ── Underwear labelled items ── */
.CharSetup__dollUnderwearItem {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  min-width: 0;
  overflow: hidden;

  .Dropdown {
    display: block;
  }

  .Dropdown__control {
    min-width: 0;
    width: 100%;
  }
}

.CharSetup__dollUnderwearRow {
  display: flex;
  align-items: stretch;
  gap: 0.1875rem;
  min-width: 0;

  .Dropdown {
    flex: 1 1 0;
    min-width: 0;
  }
}

.CharSetup__uwColorSwatch {
  flex: 0 0 1.25rem;
  width: 1.25rem;
  border-radius: 0.1875rem;
  border: 0.0625rem solid rgba(255, 255, 255, 0.18);
  cursor: pointer;
  transition: border-color 80ms ease, box-shadow 80ms ease;

  &:hover {
    border-color: rgba(255, 255, 255, 0.45);
    box-shadow: 0 0 0 0.125rem rgba(100, 140, 200, 0.30);
  }
}

.CharSetup__dollUnderwearLabel {
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(170, 178, 196, 0.40);
  padding-left: 0.125rem;
}

.CharSetup__wardrobeHint {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  gap: 0.5rem;
  color: rgba(180, 175, 160, 0.28);
  font-size: 0.8125rem;
  font-style: italic;
  text-align: center;
}

/* =========================================================
 * PILL / BADGE SYSTEM
 * ========================================================= */

.CharSetup__pill {
  display: inline-block;
  padding: 0.3125rem 0.625rem;
  border-radius: 0.75rem;
  font-weight: 700;
  font-size: 0.6875rem;
  line-height: 1.2;
  letter-spacing: 0.02em;
  vertical-align: middle;

  transition:
    filter 90ms ease,
    box-shadow 90ms ease;
}

.CharSetup__pill:hover {
}

/* Native language — green glow */
.CharSetup__pill--native {
  font-size: 0.8125rem;
  padding: 0.375rem 0.75rem;
  background: rgba(80, 200, 120, 0.20);
  color: #6fcf97;
  border: 0.0625rem solid rgba(80, 200, 120, 0.35);
}

/* Secondary/default language — blue glow */
.CharSetup__pill--secondary {
  font-size: 0.8125rem;
  padding: 0.375rem 0.75rem;
  background: rgba(100, 149, 237, 0.20);
  color: #8fb8ff;
  border: 0.0625rem solid rgba(100, 149, 237, 0.35);
}

/* Removable alt language pill */
.CharSetup__pill--removable {
  font-size: 0.8125rem;
  padding: 0.375rem 0.75rem;
  background: rgba(255, 255, 255, 0.07);
  color: rgba(235, 235, 235, 0.80);
  border: 0.0625rem solid rgba(255, 255, 255, 0.12);
}

/* Status badge — small "Written" / "Equipped" */
.CharSetup__pill--status {
  padding: 0.125rem 0.375rem;
  font-size: 0.6875rem;
  border-radius: 0.5rem;
  background: rgba(80, 200, 120, 0.18);
  color: #6fcf97;
  border: none;
  letter-spacing: 0.04em;
}

/* Counter pill */
.CharSetup__pill--count {
  padding: 0.1875rem 0.5rem;
  font-size: 0.6875rem;
  border-radius: 0.625rem;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(235, 235, 235, 0.70);
  border: 0.0625rem solid rgba(255, 255, 255, 0.10);
}

/* Counter full — red warning */
.CharSetup__pill--countFull {
  background: rgba(255, 100, 100, 0.18);
  color: #ff8a8a;
  border-color: rgba(255, 100, 100, 0.25);
}


/* =========================================================
 * FLAVOR TEXT — body part grid
 * ========================================================= */

.CharSetup__bodyPartGrid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.375rem;
}

.CharSetup__bodyPart {
  flex: 1 1 48%;
  min-width: 0;
  padding: 0.5rem;
  cursor: pointer;

  background: rgba(255, 255, 255, 0.03);
  border: 0.0625rem solid transparent;
  border-radius: 0.25rem;

  transition:
    background 100ms ease,
    border-color 100ms ease,
    box-shadow 100ms ease;
}

.CharSetup__bodyPart:hover {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.10);
}

/* Active (selected for editing) */
.CharSetup__bodyPart--active {
  background: rgba(100, 149, 237, 0.12);
  border-color: rgba(100, 149, 237, 0.40);
}

/* Filled (has text content) */
.CharSetup__bodyPart--filled {
  background: rgba(80, 200, 120, 0.06);
  border-color: rgba(80, 200, 120, 0.15);
}

/* Both active + filled */
.CharSetup__bodyPart--active.CharSetup__bodyPart--filled {
  background: rgba(100, 149, 237, 0.12);
  border-color: rgba(100, 149, 237, 0.40);
}


/* =========================================================
 * RELATION CARDS
 * ========================================================= */

.CharSetup__relation {
  margin-bottom: 0.375rem;
}

.CharSetup__relation--enabled {
  background: rgba(80, 200, 120, 0.06);
  border-color: rgba(80, 200, 120, 0.20);
}

.CharSetup__relation--enabled:hover {
  background: rgba(80, 200, 120, 0.09);
  border-color: rgba(80, 200, 120, 0.30);
}


/* =========================================================
 * PREFERENCE / SETTINGS — collapsible category cards
 * ========================================================= */

.CharSetup__prefRow {
  padding: 0.25rem 0.5rem;

  transition: background 80ms ease;
}

.CharSetup__prefRow:hover {
  background: rgba(255, 255, 255, 0.03);
}

/* Alternating stripe */
.CharSetup__prefRow--alt {
  background: rgba(255, 255, 255, 0.02);
}

.CharSetup__prefRow--alt:hover {
  background: rgba(255, 255, 255, 0.04);
}


/* =========================================================
 * HUD UI PREVIEW — theme/color/alpha preview window
 * ========================================================= */

.CharSetup__uiPreview {
  position: relative;
  width: 100%;
  height: 17rem;
  border-radius: 0.375rem;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.CharSetup__uiPreviewBg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.CharSetup__uiPreviewHud {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.CharSetup__uiPreviewItems {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: right bottom;
  pointer-events: none;
}


/* =========================================================
 * KEY BADGES — keybinding display
 * ========================================================= */

.CharSetup__keyBadge {
  display: inline-block;
  padding: 0.125rem 0.4375rem;
  margin: 0.0625rem;

  font-family: var(--cs-font-mono);
  font-weight: 700;
  font-size: 0.6875rem;
  line-height: 1.4;
  letter-spacing: 0.04em;

  background: rgba(255, 255, 255, 0.10);
  border: 0.0625rem solid rgba(255, 255, 255, 0.18);
  border-radius: 0.1875rem;

  transition:
    background 90ms ease,
    box-shadow 90ms ease,
    filter 90ms ease;
}

.CharSetup__keyBadge:hover {
  background: rgba(255, 255, 255, 0.15);
}

/* Unbound state */
.CharSetup__keyBadge--unbound {
  font-style: italic;
  opacity: 0.45;
  border-style: dashed;
}

.CharSetup__keyBadge--capturing {
  border-color: rgba(77, 182, 172, 0.6);
  background: rgba(77, 182, 172, 0.15);
  color: rgba(77, 182, 172, 0.9);
  animation: CharSetup__keyCapturePulse 1s ease-in-out infinite;
}

// Wrapper for key badge + remove button
.CharSetup__keyBadgeWrap {
  display: inline-flex;
  align-items: stretch;
  margin: 0.0625rem;
}

.CharSetup__keyBadgeWrap .CharSetup__keyBadge {
  margin: 0;
  border-radius: 0.1875rem 0 0 0.1875rem;
}

.CharSetup__keyBadgeRemove {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0 0.25rem;
  cursor: pointer;

  font-size: 0.8125rem;
  color: rgba(255, 255, 255, 0.40);
  background: rgba(255, 255, 255, 0.06);
  border: 0.0625rem solid rgba(255, 255, 255, 0.18);
  border-left: none;
  border-radius: 0 0.1875rem 0.1875rem 0;

  transition: background 90ms ease, color 90ms ease;

  &:hover {
    background: rgba(244, 67, 54, 0.25);
    color: rgba(244, 67, 54, 0.90);
  }
}

@keyframes CharSetup__keyCapturePulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}


/* =========================================================
 * IDENTITY — ID CARD
 * ========================================================= */

.CharSetup__idCard {
  position: relative;
  border-radius: 0.625rem;
  // No overflow:hidden — dropdown menus must escape card bounds.
  // Stamp clipping is handled by the stamp container itself.

  /* Card material — neutral dark grey */
  background: rgba(22, 22, 26, 0.97);

  border: 0.0625rem solid rgba(255, 255, 255, 0.10);

  /* Consistent font-size for all controls within the card */
  font-size: 0.8125rem;
}

/* Header stripe */
.CharSetup__idCardStripe {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.25rem 0.75rem;
  border-radius: 0.625rem 0.625rem 0 0;

  background: rgba(255, 255, 255, 0.05);
  border-bottom: 0.0625rem solid rgba(255, 255, 255, 0.10);
}

.CharSetup__idCardStripeLogo {
  font-size: 0.8125rem;
  font-weight: 800;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  text-shadow: 0 0.0625rem 0.25rem rgba(0, 0, 0, 0.4);
}

.CharSetup__idCardStripeRight {
  font-size: 0.75rem;
  font-family: var(--cs-font-mono);
  font-weight: 600;
  letter-spacing: 0.1em;
}

/* Main card body — photo left, fields right */
.CharSetup__idCardBody {
  display: flex;
  gap: 0.75rem;
  padding: 0.625rem 0.75rem;
}

/* Left column */
.CharSetup__idCardLeft {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  flex-shrink: 0;
  width: 7.5rem;
}

/* Photo frame */
.CharSetup__idCardPhoto {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.CharSetup__idCardPhotoInner {
  position: relative;
  width: 7rem;
  height: 7rem;
  overflow: hidden;
  border-radius: 0.25rem;

  background: rgba(0, 0, 0, 0.35);
  border: 0.125rem solid rgba(255, 255, 255, 0.12);
}

.CharSetup__idCardHeadshot {
  image-rendering: pixelated;
  position: absolute;
  width: 280%;
  height: 280%;
  top: -8%;
  left: -90%;
}

.CharSetup__idCardPhotoLabel {
  margin-top: 0.25rem;
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: rgba(180, 185, 195, 0.55);
}

/* Approval stamp — absolute overlay on the card, self-clipping */
.CharSetup__idCardStamp {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 4;
  pointer-events: none;
  overflow: hidden;
  border-radius: 0.625rem;
}

.CharSetup__idCardStampImg {
  position: absolute;
  bottom: 0.75rem;
  right: -1rem;
  width: 18rem;
  height: auto;
  image-rendering: auto;
  transform: rotate(-18deg);
  opacity: 0.50;
  mix-blend-mode: screen;
}

/* Barcode */
.CharSetup__idCardBarcode {
  font-family: var(--cs-font-mono);
  font-size: 0.6875rem;
  letter-spacing: -0.05em;
  color: rgba(255, 255, 255, 0.18);
  white-space: nowrap;
  overflow: hidden;
  width: 6.5rem;
  text-align: center;
}

/* Right column: editable fields */
.CharSetup__idCardFields {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.CharSetup__idCardField {
  min-width: 0;
}

.CharSetup__idCardFieldRow {
  display: flex;
  gap: 0.5rem;

  &--wrap {
    flex-wrap: wrap;
  }
}

.CharSetup__idCardField {
  &--half {
    flex: 1 1 calc(50% - 0.25rem);
    min-width: 7rem;
  }
}

/* In-card section separator — thin rule with centred label */
.CharSetup__idCardSectionSep {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  color: rgba(160, 165, 175, 0.30);
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin: 0.125rem 0;

  &::before,
  &::after {
    content: '';
    flex: 1;
    height: 1px;
    background: currentColor;
  }
}

.CharSetup__idCardFieldLabel {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: rgba(180, 185, 195, 0.65);
  margin-bottom: 0.1875rem;
}

/* Fixed-width age input with slightly larger font */
.CharSetup__ageInputWrap {
  .NumberInput {
    width: 5rem;
    font-size: 1rem;
    font-weight: 700;
    font-family: var(--cs-font-mono);
  }

  .NumberInput__content {
    font-size: 1rem;
    font-weight: 700;
    font-family: var(--cs-font-mono);
  }
}

/* Card footer */
.CharSetup__idCardFooter {
  display: flex;
  justify-content: space-between;
  padding: 0.25rem 0.75rem;

  font-family: var(--cs-font-mono);
  font-size: 0.6875rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: rgba(160, 165, 175, 0.45);

  border-top: 0.0625rem solid rgba(255, 255, 255, 0.07);
  border-radius: 0 0 0.625rem 0.625rem;
  background: rgba(0, 0, 0, 0.12);
}


/* =========================================================
 * ID CARD BACK — Appearance controls on the backside
 * ========================================================= */

// Divider between front and back
.CharSetup__idCardDivider {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  margin: 0.5rem 0;
  color: rgba(160, 165, 175, 0.30);
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  font-family: var(--cs-font-mono);

  &::before,
  &::after {
    content: "";
    flex: 1;
    height: 0.0625rem;
    background: linear-gradient(90deg, transparent, rgba(200, 195, 170, 0.12), transparent);
  }
}

.CharSetup__idCardBack {
  position: relative;
  border-radius: 0.625rem;
  overflow: visible;
  font-size: 0.8125rem;

  background: rgba(22, 22, 26, 0.97);

  border: 0.0625rem solid rgba(255, 255, 255, 0.10);

  // Holographic sheen overlay matching front card
  &::before {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(
      125deg,
      transparent 30%,
      rgba(100, 140, 200, 0.03) 40%,
      rgba(160, 120, 200, 0.02) 50%,
      rgba(100, 200, 200, 0.03) 60%,
      transparent 70%
    );
    pointer-events: none;
    z-index: 1;
  }
}

// Magnetic stripe — dark horizontal band at top
.CharSetup__idCardMagStripe {
  height: 2rem;
  border-radius: 0.625rem 0.625rem 0 0;
  overflow: hidden;
  background:
    repeating-linear-gradient(
      90deg,
      rgba(0, 0, 0, 0.85),
      rgba(0, 0, 0, 0.85) 0.375rem,
      rgba(10, 10, 10, 0.80) 0.375rem,
      rgba(10, 10, 10, 0.80) 0.75rem
    );
  border-bottom: 0.0625rem solid rgba(180, 170, 140, 0.06);
}

// Content area below stripe
.CharSetup__idCardBackContent {
  position: relative;
  z-index: 2;
  padding: 0.5rem 0.75rem;
}

// Section label within back card
.CharSetup__idCardBackLabel {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  color: rgba(180, 185, 195, 0.65);
  font-family: var(--cs-font-mono);
  margin-bottom: 0.375rem;
  padding-bottom: 0.1875rem;
  border-bottom: 0.0625rem solid rgba(200, 195, 170, 0.06);
}

// Two-column layout for styles + colors
.CharSetup__idCardBackColumns {
  display: flex;
  gap: 0.75rem;
}

.CharSetup__idCardBackCol {
  flex: 1;
  min-width: 0;
}

// Color swatch row (eye/hair/etc)
.CharSetup__idCardColorRow {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.375rem;
}

.CharSetup__idCardColorLabel {
  font-size: 0.8125rem;
  font-weight: 600;
  color: rgba(195, 200, 215, 0.70);
  min-width: 5rem;
  font-family: var(--cs-font-mono);
}

.CharSetup__idCardColorSwatch {
  width: 1.5rem;
  height: 1.5rem;
  border-radius: 0.125rem;
  border: 0.0625rem solid rgba(255, 255, 255, 0.12);
  flex-shrink: 0;
}

// Marking row
.CharSetup__idCardMarkingRow {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.25rem 0.375rem;
  margin-bottom: 0.125rem;
  background: rgba(0, 0, 0, 0.15);
  border: 0.0625rem solid rgba(255, 255, 255, 0.03);
  border-radius: 0.125rem;
  font-size: 0.8125rem;
  color: rgba(195, 200, 215, 0.75);
}

// Signature strip at bottom
.CharSetup__idCardSignature {
  margin-top: 0.75rem;
  padding: 0.375rem 0.5rem;
  background:
    repeating-linear-gradient(
      0deg,
      rgba(200, 195, 170, 0.03),
      rgba(200, 195, 170, 0.03) 0.0625rem,
      transparent 0.0625rem,
      transparent 0.375rem
    ),
    rgba(200, 195, 170, 0.04);
  border-radius: 0.125rem;
  display: flex;
  justify-content: space-between;
  font-family: var(--cs-font-mono);
  font-size: 0.6875rem;
  font-weight: 600;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  color: rgba(200, 195, 170, 0.35);
}

/* =========================================================
 * SPECIES INFO BLURB
 * ========================================================= */

.CharSetup__infoBlurb {
  padding: 0.625rem;
  font-size: 0.75rem;
  line-height: 1.5;
  color: rgba(235, 235, 235, 0.65);

  background: rgba(0, 0, 0, 0.20);
  border-radius: 0.25rem;
  border: 0.0625rem solid rgba(255, 255, 255, 0.04);
}


/* =========================================================
 * COLOR SWATCH
 * ========================================================= */

.CharSetup__colorSwatch {
  display: inline-block;
  width: 1.125rem;
  height: 1.125rem;
  min-width: 1.125rem;
  margin: 0.0625rem;
  border-radius: 0.125rem;
  cursor: pointer;

  border: 0.0625rem solid rgba(255, 255, 255, 0.25);

  transition:
    border-color 80ms ease,
    box-shadow 80ms ease,
    transform 80ms ease;
}

.CharSetup__colorSwatch:hover {
  border-color: rgba(255, 255, 255, 0.55);
  transform: scale(1.15);
}

/* Selected swatch */
.CharSetup__colorSwatch--selected {
  border: 0.125rem solid white;
}

/* Small inline color preview dot */
.CharSetup__colorDot {
  display: inline-block;
  width: 0.75rem;
  height: 0.75rem;
  border-radius: 0.0625rem;
  vertical-align: middle;
  border: 0.0625rem solid rgba(255, 255, 255, 0.40);
}


/* =========================================================
 * GEAR ITEM LIST — loadout items
 * ========================================================= */


.CharSetup__gearRow {
  cursor: pointer;
  border-radius: 0.1875rem;
  margin: 0.0625rem 0;
  padding: 0.25rem 0.3125rem;
  font-size: 14px;

  border-left: 0.125rem solid transparent;

  transition:
    background 80ms ease,
    border-color 100ms ease,
    box-shadow 100ms ease;
}

.CharSetup__gearRow:hover {
  background: rgba(130, 145, 168, 0.06);
  border-left-color: rgba(130, 145, 168, 0.20);
}

.CharSetup__gearRow--selected {
  background: rgba(130, 145, 168, 0.28);
  border-left-color: rgba(130, 145, 168, 1);
  border-left-width: 3px;
}

.CharSetup__gearRow--equipped {
  border-left-color: rgba(80, 200, 120, 0.50);
  background: rgba(60, 180, 100, 0.08);
}

.CharSetup__gearRow--equipped:hover {
  border-left-color: rgba(80, 200, 120, 0.70);
  background: rgba(60, 180, 100, 0.14);
}

.CharSetup__gearRow--unavailable {
  opacity: 0.45;
  cursor: not-allowed;
  pointer-events: none;
}

/* Right-click context menu */
.CharSetup__ctxMenuBackdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 100;
}

.CharSetup__ctxMenu {
  position: fixed;
  min-width: 140px;
  background: rgba(20, 20, 25, 0.95);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 0.25rem;
  z-index: 101;
  overflow: hidden;
}

.CharSetup__ctxMenuHeader {
  padding: 0.35rem 0.5rem;
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.5);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

.CharSetup__ctxMenuItem {
  padding: 0.35rem 0.5rem;
  font-size: 0.8125rem;
  cursor: pointer;
  white-space: nowrap;
  transition: background 80ms ease;

  &:hover {
    background: rgba(130, 145, 168, 0.15);
  }
}

.CharSetup__gearIcon {
  width: 2rem;
  height: 2rem;
  image-rendering: pixelated;

  background: radial-gradient(circle, rgba(130, 145, 168, 0.04), transparent 70%);
  border-radius: 0.125rem;
}

.CharSetup__gearIcon .game-icon,
.CharSetup__gearIcon .CharSetup__gearSpriteIcon {
  width: 2rem;
  height: 2rem;
  image-rendering: pixelated;
}


/* =========================================================
 * GEAR DETAIL — selected item panel
 * ========================================================= */

.CharSetup__gearDetail {
  padding: 0.75rem;
  background:
    linear-gradient(180deg, rgba(22, 22, 26, 0.70), rgba(10, 15, 28, 0.80));
  border-radius: 0.375rem;
  border: 0.0625rem solid rgba(130, 145, 168, 0.10);
  border: 0.0625rem solid var(--cs-border-subtle);
}

.CharSetup__gearDetailIcon {
  width: 3rem;
  height: 3rem;
  image-rendering: pixelated;
}

.CharSetup__gearDetailIcon .game-icon,
.CharSetup__gearDetailIcon .CharSetup__gearSpriteIcon {
  width: 3rem;
  height: 3rem;
  image-rendering: pixelated;
}


/* =========================================================
 * LAYOUT — overall structure overrides
 * ========================================================= */

/* Main three-column layout — frosted glass treatment */
.CharSetup__layout {
  height: 100%;
}

/* Override the Window.Content background for CharSetup */
.CharSetup.Layout__content {
  background-color: #1e1e22 !important;
}


/* =========================================================
 * DIVIDER — gradient line with glow
 * ========================================================= */

.CharSetup .Divider--horizontal {
  border-top: 0.0625rem solid rgba(255, 255, 255, 0.08);
  margin: 0.5rem 0;
}

.CharSetup .Divider--vertical {
  border-left: none;
  width: 0.0625rem;
  background: linear-gradient(
    180deg,
    transparent,
    rgba(130, 145, 168, 0.12) 20%,
    rgba(130, 145, 168, 0.06) 80%,
    transparent
  );
  margin: 0 0.375rem;
}


/* =========================================================
 * SECTION OVERRIDES — right panel
 * ========================================================= */

.CharSetup .Section {
  background-color: rgba(12, 12, 14, 0.85);
  border: 0.0625rem solid rgba(130, 145, 168, 0.08);
  border-radius: 0.375rem;
}

/* Section title — bold uppercase with gradient underline */
.CharSetup .Section__title {
  font-weight: 900;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  font-size: 0.8125rem;
  color: rgba(170, 178, 196, 0.90);
  padding: 0.625rem 0.75rem;
  border-bottom: none;

  background: linear-gradient(
    180deg,
    rgba(130, 145, 168, 0.06) 0%,
    rgba(130, 145, 168, 0.02) 60%,
    transparent 100%
  );
}

.CharSetup .Section__title::after {
  content: "";
  display: block;
  margin-top: 0.375rem;
  height: 0.0625rem;
  background: linear-gradient(
    90deg,
    var(--cs-accent, rgba(130, 145, 168, 0.40)),
    rgba(130, 145, 168, 0.10) 50%,
    transparent 100%
  );
}

.CharSetup .Section__content {
  padding: 0.05rem 0.75rem;
}



/* =========================================================
 * BUTTON OVERRIDES — keep for any remaining TGUI Buttons
 * ========================================================= */

.CharSetup .Button {
  border-radius: 0.1875rem;
  transition:
    background-color 80ms ease,
    border-color 80ms ease,
    color 80ms ease;
}

// Override default button colour to neutral grey (TGUI default is blue)
.CharSetup .Button--color--default {
  background-color: rgba(55, 55, 62, 0.95);
  color: rgba(210, 215, 225, 0.90);

  &:hover {
    background-color: rgba(72, 72, 82, 0.95);
    color: rgba(225, 230, 240, 1);
  }

  &:active {
    background-color: rgba(42, 42, 50, 0.95);
  }
}

// Selected state — highlight with accent colour
.CharSetup .Button--selected {
  background-color: rgba(56, 86, 124, 0.90) !important;
  color: rgba(190, 210, 240, 1) !important;

  &:hover {
    background-color: rgba(68, 102, 146, 0.95) !important;
  }
}

/* =========================================================
 * CUSTOM BUTTONS — CsButton (CharSetup__btn)
 * ========================================================= */

.CharSetup__btn {
  display: inline-flex;
  align-items: center;
  padding: 0.375rem 0.75rem;
  font-size: 0.8125rem;
  font-weight: 600;
  font-family: var(--cs-font-mono);
  letter-spacing: 0.03em;
  color: rgba(230, 235, 245, 0.95);
  cursor: pointer;
  user-select: none;

  background:
    linear-gradient(180deg, rgba(56, 86, 124, 0.65) 0%, rgba(46, 72, 106, 0.70) 100%);
  border: 0.0625rem solid rgba(130, 145, 168, 0.12);
  border-radius: 0.1875rem;

  transition:
    background 120ms ease,
    border-color 120ms ease,
    box-shadow 120ms ease,
    transform 80ms ease,
    color 120ms ease;

  &:hover {
    color: rgba(220, 230, 245, 0.95);
    border-color: rgba(130, 145, 168, 0.28);
    background:
      linear-gradient(180deg, rgba(70, 104, 148, 0.72) 0%, rgba(56, 86, 124, 0.77) 100%);
  }

  &:active {
    transform: translateY(0.0625rem);
    background:
      linear-gradient(180deg, rgba(42, 66, 100, 0.80) 0%, rgba(34, 54, 84, 0.85) 100%);
  }

  .Icon {
    font-size: 0.8125rem;
  }
}

.CharSetup__btn--selected {
  color: rgba(100, 165, 225, 0.95);
  border-color: rgba(130, 145, 168, 0.35);
  background:
    linear-gradient(180deg, rgba(50, 82, 124, 0.75) 0%, rgba(40, 66, 106, 0.80) 100%);
}

.CharSetup__btn--compact {
  padding: 0.25rem 0.5rem;
  font-size: 0.75rem;
}

.CharSetup__btn--fluid {
  display: flex;
  width: 100%;
}

.CharSetup__btn--disabled {
  opacity: 0.35;
  pointer-events: none;
  filter: grayscale(0.3);
}

.CharSetup__btn--danger {
  color: rgba(240, 130, 120, 0.90);
  border-color: rgba(244, 67, 54, 0.20);
  background:
    linear-gradient(180deg, rgba(70, 30, 30, 0.65) 0%, rgba(50, 20, 20, 0.70) 100%);

  &:hover {
    color: rgba(255, 150, 140, 0.95);
    border-color: rgba(244, 67, 54, 0.40);
  }
}

.CharSetup__btn--success {
  color: rgba(130, 210, 150, 0.90);
  border-color: rgba(100, 200, 130, 0.20);
  background:
    linear-gradient(180deg, rgba(30, 60, 35, 0.65) 0%, rgba(20, 45, 25, 0.70) 100%);

  &:hover {
    color: rgba(150, 230, 170, 0.95);
    border-color: rgba(100, 200, 130, 0.40);
  }
}

// good / bad / average / label — TGUI semantic color aliases
.CharSetup__btn--good,
.CharSetup__btn--green {
  color: rgba(130, 210, 150, 0.90);
  border-color: rgba(100, 200, 130, 0.20);
  background:
    linear-gradient(180deg, rgba(30, 60, 35, 0.65) 0%, rgba(20, 45, 25, 0.70) 100%);

  &:hover {
    color: rgba(150, 230, 170, 0.95);
    border-color: rgba(100, 200, 130, 0.40);
  }
}

.CharSetup__btn--bad,
.CharSetup__btn--red {
  color: rgba(240, 130, 120, 0.90);
  border-color: rgba(244, 67, 54, 0.20);
  background:
    linear-gradient(180deg, rgba(70, 30, 30, 0.65) 0%, rgba(50, 20, 20, 0.70) 100%);

  &:hover {
    color: rgba(255, 150, 140, 0.95);
    border-color: rgba(244, 67, 54, 0.40);
  }
}

.CharSetup__btn--average,
.CharSetup__btn--orange {
  color: rgba(255, 180, 80, 0.90);
  border-color: rgba(230, 150, 40, 0.22);
  background:
    linear-gradient(180deg, rgba(65, 45, 15, 0.65) 0%, rgba(50, 35, 10, 0.70) 100%);

  &:hover {
    color: rgba(255, 200, 110, 0.95);
    border-color: rgba(230, 150, 40, 0.42);
  }
}

.CharSetup__btn--teal {
  color: rgba(80, 210, 200, 0.90);
  border-color: rgba(40, 180, 170, 0.22);
  background:
    linear-gradient(180deg, rgba(15, 55, 55, 0.65) 0%, rgba(10, 40, 40, 0.70) 100%);

  &:hover {
    color: rgba(110, 230, 220, 0.95);
    border-color: rgba(40, 180, 170, 0.42);
  }
}

.CharSetup__btn--gold {
  color: rgba(255, 210, 80, 0.90);
  border-color: rgba(220, 180, 40, 0.22);
  background:
    linear-gradient(180deg, rgba(65, 55, 10, 0.65) 0%, rgba(50, 42, 8, 0.70) 100%);

  &:hover {
    color: rgba(255, 225, 110, 0.95);
    border-color: rgba(220, 180, 40, 0.42);
  }
}

.CharSetup__btn--blue {
  color: rgba(120, 175, 245, 0.95);
  border-color: rgba(80, 140, 220, 0.35);
  background:
    linear-gradient(180deg, rgba(30, 60, 110, 0.80) 0%, rgba(22, 48, 90, 0.85) 100%);

  &:hover {
    color: rgba(155, 200, 255, 1);
    border-color: rgba(80, 140, 220, 0.55);
  }
}

.CharSetup__btn--pink {
  color: rgba(245, 140, 185, 0.95);
  border-color: rgba(210, 90, 150, 0.35);
  background:
    linear-gradient(180deg, rgba(100, 30, 65, 0.80) 0%, rgba(80, 22, 50, 0.85) 100%);

  &:hover {
    color: rgba(255, 165, 205, 1);
    border-color: rgba(210, 90, 150, 0.55);
  }
}

.CharSetup__btn--label {
  color: rgba(180, 175, 160, 0.55);
  border-color: rgba(255, 255, 255, 0.07);
  background:
    linear-gradient(180deg, rgba(30, 30, 35, 0.45) 0%, rgba(22, 22, 28, 0.50) 100%);

  &:hover {
    color: rgba(200, 195, 175, 0.70);
  }
}

.CharSetup__btn--checkbox {
  background:
    linear-gradient(180deg, rgba(46, 72, 108, 0.50) 0%, rgba(36, 58, 90, 0.55) 100%);
  border-color: rgba(130, 145, 168, 0.08);
  font-weight: 500;
  color: rgba(195, 200, 215, 0.60);
}

.CharSetup__btn--checked {
  color: rgba(100, 165, 225, 0.85);
  border-color: rgba(130, 145, 168, 0.22);
}


/* =========================================================
 * INPUT OVERRIDES — glowing border on focus
 * ========================================================= */

.CharSetup .Input {
  background: rgba(0, 0, 0, 0.35);
  border: 0.0625rem solid rgba(130, 145, 168, 0.20);
  border-radius: 0.1875rem;

  transition: border-color 150ms ease, box-shadow 150ms ease;
}

.CharSetup .Input:focus-within {
  border-color: rgba(130, 145, 168, 0.50);
}


/* =========================================================
 * NUMBER INPUT — dark inset with blue accent
 * ========================================================= */

.CharSetup .NumberInput {
  border: 0.0625rem solid rgba(130, 145, 168, 0.15);
  border-radius: 0.1875rem;
  background:
    linear-gradient(180deg, rgba(10, 14, 22, 0.80) 0%, rgba(15, 20, 32, 0.75) 100%);
  color: rgba(195, 200, 215, 0.90);
  font-family: var(--cs-font-mono);

  transition: border-color 120ms ease, box-shadow 120ms ease;

  &:hover {
    border-color: rgba(130, 145, 168, 0.28);
  }
}

.CharSetup .NumberInput__bar {
  background-color: rgba(130, 145, 168, 0.50);
  border-bottom-color: rgba(130, 145, 168, 0.70);
}

.CharSetup .NumberInput__input {
  background: transparent;
  color: rgba(195, 200, 215, 0.90);
  font-family: var(--cs-font-mono);
}


/* =========================================================
 * DROPDOWN OVERRIDES — dark glass with blue glow
 * ========================================================= */

.CharSetup .Dropdown__control {
  border: 0.0625rem solid rgba(130, 145, 168, 0.12) !important;
  border-radius: 0.1875rem !important;
  background: linear-gradient(180deg, rgba(56, 86, 124, 0.65) 0%, rgba(46, 72, 106, 0.70) 100%) !important;
  color: rgba(230, 235, 245, 0.95) !important;
  font-family: var(--cs-font-mono);
  letter-spacing: 0.02em;

  transition: background 80ms ease, border-color 80ms ease !important;
}

.CharSetup .Dropdown__control:hover {
  background: linear-gradient(180deg, rgba(70, 104, 148, 0.72) 0%, rgba(56, 86, 124, 0.77) 100%) !important;
  border-color: rgba(130, 145, 168, 0.28) !important;
  color: rgba(220, 228, 245, 0.95) !important;
}

// Native select popup colours — Chromium applies background-color/color to the list.
.CharSetup .Dropdown__native {
  background-color: #2e4a6a;
  color: rgba(230, 235, 245, 0.95);
  font-family: var(--cs-font-mono);
}

.CharSetup .Dropdown__native option {
  background-color: #2e4a6a;
  color: rgba(230, 235, 245, 0.95);
}

.CharSetup .Dropdown__native option:checked {
  background-color: #3d618a;
  color: rgba(220, 225, 235, 1);
}



/* =========================================================
 * TEXTAREA OVERRIDES — dark inset
 * ========================================================= */

.CharSetup .TextArea {
  background: rgba(0, 0, 0, 0.35);
  border: 0.0625rem solid rgba(130, 145, 168, 0.12);
  border-radius: 0.1875rem;

  transition: border-color 150ms ease, box-shadow 150ms ease;
}

.CharSetup .TextArea:focus,
.CharSetup .TextArea:focus-within {
  border-color: rgba(130, 145, 168, 0.35);
}

.CharSetup .TextArea__textarea {
  color: rgba(210, 215, 228, 0.92);
  font-size: 13px;
  line-height: 1.45;
  padding: 0.375rem 0.5rem;
}


/* =========================================================
 * TABS OVERRIDES — glow tabs for sub-panels
 * ========================================================= */

.CharSetup .Tabs {
  border-bottom: 0.0625rem solid rgba(130, 145, 168, 0.08);
  margin-bottom: 0.375rem;
}

.CharSetup .Tabs .Tab {
  border-radius: 0.1875rem 0.1875rem 0 0;
  transition:
    background 100ms ease,
    color 100ms ease,
    box-shadow 100ms ease;
}

.CharSetup .Tabs .Tab:hover {
  background: rgba(130, 145, 168, 0.06);
}

.CharSetup .Tabs .Tab--selected {
  background: rgba(130, 145, 168, 0.10);
  border-bottom: 0.125rem solid rgba(130, 145, 168, 0.50);
}


/* =========================================================
 * TABLE / CANDYSTRIPE OVERRIDES
 * ========================================================= */

.CharSetup .Table {
  border-collapse: separate;
  border-spacing: 0 0.0625rem;
}

.CharSetup .Table__row.candystripe:nth-child(odd) {
  background: rgba(255, 255, 255, 0.015);
}

.CharSetup .Table__row.candystripe:nth-child(even) {
  background: rgba(130, 145, 168, 0.015);
}

.CharSetup .Table__row:hover {
  background: rgba(130, 145, 168, 0.06) !important;
}


/* =========================================================
 * COLORBOX OVERRIDES — softer with glow
 * ========================================================= */

.CharSetup .ColorBox {
  border: 0.0625rem solid rgba(255, 255, 255, 0.25);
  border-radius: 0.125rem;
}


/* =========================================================
 * SLIDER OVERRIDES — dark track with blue fill
 * ========================================================= */

.CharSetup .Slider {
  border: 0.0625rem solid rgba(255, 255, 255, 0.10);
  border-radius: 0.1875rem;
  background: rgba(55, 55, 62, 0.95);
  color: rgba(225, 228, 238, 0.92);
  font-family: var(--cs-font-mono);

  transition: border-color 80ms ease;

  &:hover {
    border-color: rgba(255, 255, 255, 0.16);
  }
}

.CharSetup .Slider .ProgressBar__fill {
  background: rgba(91, 143, 196, 0.30);
}

.CharSetup .Slider__cursor {
  border-left-color: rgba(220, 225, 238, 0.90);
}

.CharSetup .Slider__pointer {
  border-bottom-color: rgba(220, 225, 238, 0.90);
}

.CharSetup .Slider__popupValue {
  background: rgba(30, 30, 36, 0.97);
  border: 0.0625rem solid rgba(255, 255, 255, 0.14);
  border-radius: 0.125rem;
  color: rgba(225, 228, 238, 0.95);
  font-family: var(--cs-font-mono);
}

/* ── Skin Tone slider — gradient track + solid handle ── */

// Track: real skin gradient derived from game formula
// rgb(200+s_tone, 150+s_tone, 123+s_tone): lightest(s+35)→darkest(s-185)
.CharSetup__skinToneSlider .Slider {
  background: linear-gradient(
    90deg,
    #ebb99e 0%,
    #c8967b 35%,
    #8c5438 65%,
    #3c1a08 100%
  ) !important;
  border-color: rgba(0, 0, 0, 0.30) !important;

  &:hover {
    border-color: rgba(0, 0, 0, 0.45) !important;
  }
}

// The fill covers the left portion — hide it so the full gradient shows
.CharSetup__skinToneSlider .Slider .ProgressBar__fill {
  background: transparent !important;
}

// Cursor: solid rectangular handle centered on the right edge of the fill
.CharSetup__skinToneSlider .Slider__cursor {
  width: 0.625rem;
  right: -0.3125rem;
  border-left: none !important;
  background: rgba(240, 240, 248, 0.95);
  border-radius: 0.125rem;
  border: 0.0625rem solid rgba(0, 0, 0, 0.35) !important;
}

.CharSetup__skinToneSlider .Slider__pointer {
  display: none;
}

.CharSetup__skinToneSlider .Slider__popupValue {
  background: rgba(30, 30, 36, 0.97);
  border-color: rgba(0, 0, 0, 0.40) !important;
}


/* =========================================================
 * FIELD LABELS — subtle uppercase treatment
 * ========================================================= */

.CharSetup__fieldLabel {
  font-weight: 700;
  font-size: 0.75rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(170, 178, 196, 0.65);
  margin-bottom: 0.375rem;
}


/* =========================================================
 * ANIMATIONS — keyframes
 * ========================================================= */

/* Scan line sweep on preview frame */
@keyframes charsetupScanLine {
  0%   { background-position: 0 -12rem; }
  100% { background-position: 0 24rem; }
}

/* Subtle glow pulse for selected elements */
@keyframes charsetupPulse {
  0%, 100% { opacity: 0.65; }
  50%      { opacity: 1; }
}

/* Slide-in for panel content transitions */
@keyframes charsetupSlideIn {
  from {
    opacity: 0;
    transform: translateY(0.25rem);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}


/* =========================================================
 * PERSONALITY — Medical Record / Dossier interface
 * ========================================================= */

// Main container
.CharSetup__medPanel {
  display: flex;
  flex-direction: column;
  height: 100%;
}

// File-folder tab bar
.CharSetup__medTabBar {
  display: flex;
  gap: 0.125rem;
  flex-shrink: 0;
  padding: 0 0.25rem;
}

.CharSetup__medTab {
  --med-accent: #81c784;

  padding: 0.375rem 0.75rem;
  font-size: 0.8125rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
  color: rgba(235, 235, 235, 0.55);
  cursor: pointer;
  border-radius: 0.25rem 0.25rem 0 0;
  background: rgba(255, 255, 255, 0.02);
  border: 0.0625rem solid rgba(255, 255, 255, 0.04);
  border-bottom: none;
  transition: all 120ms ease;
  position: relative;

  &:hover {
    background: rgba(255, 255, 255, 0.05);
    color: rgba(235, 235, 235, 0.80);
  }
}

.CharSetup__medTab--active {
  background: rgba(0, 0, 0, 0.25);
  color: var(--med-accent);
  border-color: rgba(255, 255, 255, 0.08);

  // Top edge glow
  &::before {
    content: "";
    position: absolute;
    top: 0;
    left: 0.25rem;
    right: 0.25rem;
    height: 0.125rem;
    background: var(--med-accent);
    border-radius: 0.125rem;
  }
}

// Document body — the "paper"
.CharSetup__medBody {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: 0.75rem;
  background:
    // Faint lined paper effect
    repeating-linear-gradient(
      180deg,
      transparent,
      transparent 1.625rem,
      rgba(255, 255, 255, 0.015) 1.625rem,
      rgba(255, 255, 255, 0.015) 1.6875rem
    ),
    // Red left margin line
    linear-gradient(90deg, transparent 1.5rem, rgba(200, 80, 80, 0.06) 1.5rem, rgba(200, 80, 80, 0.06) 1.5625rem, transparent 1.5625rem),
    rgba(0, 0, 0, 0.25);
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  border-top: none;
  border-radius: 0 0 0.375rem 0.375rem;
}

// Document header block
.CharSetup__medDocHeader {
  padding: 0.625rem 0.75rem;
  margin-bottom: 0.75rem;
  background:
    linear-gradient(135deg, rgba(129, 199, 132, 0.08) 0%, rgba(129, 199, 132, 0.02) 100%),
    rgba(0, 0, 0, 0.30);
  border: 0.0625rem solid rgba(129, 199, 132, 0.18);
  border-radius: 0.25rem;
  border-left: 0.1875rem solid rgba(129, 199, 132, 0.50);
}

.CharSetup__medDocHeader--red {
  background:
    linear-gradient(135deg, rgba(229, 115, 115, 0.08) 0%, rgba(229, 115, 115, 0.02) 100%),
    rgba(0, 0, 0, 0.30);
  border-color: rgba(229, 115, 115, 0.18);
  border-left-color: rgba(229, 115, 115, 0.50);
}

.CharSetup__medDocHeader--blue {
  background:
    linear-gradient(135deg, rgba(121, 134, 203, 0.08) 0%, rgba(121, 134, 203, 0.02) 100%),
    rgba(0, 0, 0, 0.30);
  border-color: rgba(121, 134, 203, 0.18);
  border-left-color: rgba(121, 134, 203, 0.50);
}

.CharSetup__medDocIcon {
  font-size: 1.5rem;
  color: rgba(129, 199, 132, 0.70);
  filter: drop-shadow(0 0 0.25rem rgba(129, 199, 132, 0.30));

  .CharSetup__medDocHeader--red & {
    color: rgba(229, 115, 115, 0.70);
    filter: drop-shadow(0 0 0.25rem rgba(229, 115, 115, 0.30));
  }

  .CharSetup__medDocHeader--blue & {
    color: rgba(121, 134, 203, 0.70);
    filter: drop-shadow(0 0 0.25rem rgba(121, 134, 203, 0.30));
  }
}

.CharSetup__medDocTitle {
  font-size: 1.0625rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  color: rgba(235, 235, 235, 0.90);
  font-family: var(--cs-font-mono);
}

.CharSetup__medDocSub {
  font-size: 0.8125rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  color: rgba(235, 235, 235, 0.55);
  font-family: var(--cs-font-mono);
  text-transform: uppercase;
}

// "N NOTED" badge
.CharSetup__medBadge {
  padding: 0.25rem 0.5rem;
  font-size: 0.8125rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  letter-spacing: 0.06em;
  color: rgba(129, 199, 132, 0.85);
  background: rgba(129, 199, 132, 0.10);
  border: 0.0625rem solid rgba(129, 199, 132, 0.25);
  border-radius: 0.1875rem;
}

// Category tabs (Physical/Mental/Social...)
.CharSetup__medCatBar {
  display: flex;
  gap: 0.25rem;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
}

.CharSetup__medCatTab {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: rgba(235, 235, 235, 0.60);
  cursor: pointer;
  border-radius: 0.1875rem;
  background: rgba(255, 255, 255, 0.03);
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  transition: all 120ms ease;

  &:hover {
    background: rgba(255, 255, 255, 0.06);
    color: rgba(235, 235, 235, 0.85);
  }
}

.CharSetup__medCatTab--active {
  color: #81c784;
  background: rgba(129, 199, 132, 0.08);
  border-color: rgba(129, 199, 132, 0.25);
}

.CharSetup__medCatCount {
  display: inline-block;
  margin-left: 0.375rem;
  padding: 0 0.25rem;
  min-width: 0.875rem;
  text-align: center;
  font-size: 0.75rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(129, 199, 132, 0.90);
  background: rgba(129, 199, 132, 0.18);
  border-radius: 0.625rem;
}

// Section blocks
.CharSetup__medSection {
  margin-bottom: 0.75rem;
}

.CharSetup__medSectionHead {
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: rgba(129, 199, 132, 0.80);
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
  padding-bottom: 0.25rem;
  margin-bottom: 0.375rem;
  border-bottom: 0.0625rem solid rgba(129, 199, 132, 0.10);
}

.CharSetup__medSectionHead--red {
  color: rgba(229, 115, 115, 0.80);
  border-bottom-color: rgba(229, 115, 115, 0.10);
}

.CharSetup__medSectionHead--blue {
  color: rgba(121, 134, 203, 0.80);
  border-bottom-color: rgba(121, 134, 203, 0.10);
}

// Pre-existing condition row
.CharSetup__medConditionRow {
  padding: 0.375rem 0.5rem;
  border-radius: 0.1875rem;
  cursor: pointer;
  border: 0.0625rem solid transparent;
  transition: all 120ms ease;

  &:hover {
    background: rgba(255, 255, 255, 0.03);
  }
}

.CharSetup__medConditionRow--active {
  background: rgba(255, 193, 7, 0.05);
  border-color: rgba(255, 193, 7, 0.15);
}

.CharSetup__medCondCheck {
  width: 1.375rem;
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.25);

  .CharSetup__medConditionRow--active & {
    color: rgba(255, 193, 7, 0.80);
  }
}

.CharSetup__medCondDesc {
  font-size: 0.875rem;
  color: rgba(235, 235, 235, 0.55);
  font-style: italic;
}

// "CONFIRMED" rubber stamp on conditions
.CharSetup__medStamp {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.10em;
  font-family: var(--cs-font-mono);
  color: rgba(255, 193, 7, 0.75);
  border: 0.0625rem solid rgba(255, 193, 7, 0.35);
  padding: 0.0625rem 0.375rem;
  border-radius: 0.125rem;
  transform: rotate(-3deg);
}

// Trait list
.CharSetup__medTraitList {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

// Individual trait row
.CharSetup__medTraitRow {
  padding: 0.375rem 0.5rem;
  border-radius: 0.1875rem;
  cursor: pointer;
  border-left: 0.125rem solid transparent;
  transition: all 120ms ease;

  &:hover {
    background: rgba(255, 255, 255, 0.03);
    border-left-color: rgba(255, 255, 255, 0.10);
  }
}

.CharSetup__medTraitRow--active {
  background: rgba(129, 199, 132, 0.04);
  border-left-color: rgba(129, 199, 132, 0.50);

  &:hover {
    background: rgba(129, 199, 132, 0.08);
  }
}

.CharSetup__medTraitRow--conflict {
  background: rgba(244, 67, 54, 0.04);
  border-left-color: rgba(244, 67, 54, 0.30);

  &:hover {
    background: rgba(244, 67, 54, 0.06);
  }
}

.CharSetup__medTraitCheck {
  width: 1.375rem;
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.18);
  transition: color 120ms ease;
}

.CharSetup__medTraitCheck--on {
  color: #81c784;
  filter: drop-shadow(0 0 0.1875rem rgba(129, 199, 132, 0.40));
}

.CharSetup__medTraitCheck--conflict {
  color: rgba(244, 67, 54, 0.60);
}

.CharSetup__medTraitName {
  font-size: 1rem;
  font-weight: 700;
  color: rgba(235, 235, 235, 0.85);
}

// "DOCUMENTED" inline stamp
.CharSetup__medTraitStamp {
  display: inline-block;
  margin-left: 0.5rem;
  padding: 0 0.25rem;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  font-family: var(--cs-font-mono);
  color: rgba(129, 199, 132, 0.70);
  border: 0.0625rem solid rgba(129, 199, 132, 0.30);
  border-radius: 0.125rem;
  vertical-align: middle;
  transform: rotate(-2deg);
}

.CharSetup__medTraitDesc {
  font-size: 0.9375rem;
  color: rgba(235, 235, 235, 0.60);
  line-height: 1.35;
  margin-top: 0.0625rem;
}

.CharSetup__medTraitConflict {
  font-size: 0.8125rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(244, 67, 54, 0.75);
  margin-top: 0.125rem;
}

// === ANTAGONIST DOSSIER styles ===

.CharSetup__medBulkBtn {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  margin: 0 0.0625rem;
  font-size: 0.8125rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  font-family: var(--cs-font-mono);
  color: rgba(235, 235, 235, 0.65);
  background: rgba(255, 255, 255, 0.04);
  border: 0.0625rem solid rgba(255, 255, 255, 0.08);
  border-radius: 0.125rem;
  cursor: pointer;
  transition: all 120ms ease;

  &:hover {
    background: rgba(229, 115, 115, 0.12);
    color: rgba(229, 115, 115, 0.90);
    border-color: rgba(229, 115, 115, 0.25);
  }
}

.CharSetup__medAntagRow {
  padding: 0.3125rem 0.5rem;
  border-left: 0.125rem solid transparent;
  transition: all 100ms ease;

  &:nth-child(even) {
    background: rgba(255, 255, 255, 0.015);
  }
}

.CharSetup__medAntagRow--high {
  border-left-color: rgba(229, 115, 115, 0.50);
  background: rgba(229, 115, 115, 0.03);
}

.CharSetup__medAntagRow--low {
  border-left-color: rgba(255, 183, 77, 0.40);
  background: rgba(255, 183, 77, 0.02);
}

.CharSetup__medAntagName {
  font-size: 1.0625rem;
  font-weight: 600;
  color: rgba(235, 235, 235, 0.90);
}

.CharSetup__medAntagBanned {
  font-size: 0.75rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  letter-spacing: 0.06em;
  color: rgba(244, 67, 54, 0.55);
  padding: 0.125rem 0.375rem;
  border: 0.0625rem solid rgba(244, 67, 54, 0.20);
  border-radius: 0.125rem;
}

.CharSetup__medAntagPrio {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.5rem;
  margin: 0 0.0625rem;
  font-size: 0.8125rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  letter-spacing: 0.04em;
  color: rgba(235, 235, 235, 0.45);
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  border-radius: 0.125rem;
  cursor: pointer;
  transition: all 120ms ease;

  &:hover {
    background: rgba(255, 255, 255, 0.04);
    color: rgba(235, 235, 235, 0.70);
  }
}

.CharSetup__medAntagPrio--active {
  background: rgba(255, 255, 255, 0.05);
}

// === UPLINK / COMMS styles ===

.CharSetup__medCommsNote {
  font-size: 0.875rem;
  color: rgba(121, 134, 203, 0.75);
  font-family: var(--cs-font-mono);
  padding: 0.375rem 0.5rem;
  margin-bottom: 0.5rem;
  background: rgba(121, 134, 203, 0.04);
  border: 0.0625rem solid rgba(121, 134, 203, 0.10);
  border-radius: 0.1875rem;
}

.CharSetup__medCommsRow {
  padding: 0.375rem 0.5rem;
  margin-bottom: 0.125rem;
  background: rgba(0, 0, 0, 0.15);
  border: 0.0625rem solid rgba(121, 134, 203, 0.08);
  border-radius: 0.1875rem;
  transition: all 120ms ease;

  &:hover {
    border-color: rgba(121, 134, 203, 0.18);
    background: rgba(121, 134, 203, 0.04);
  }
}

.CharSetup__medCommsIndex {
  font-size: 0.9375rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(121, 134, 203, 0.65);
  width: 1.5rem;
  text-align: center;
}

.CharSetup__medCommsName {
  font-size: 1rem;
  font-weight: 700;
  color: rgba(235, 235, 235, 0.85);
}

.CharSetup__medCommsDesc {
  font-size: 0.8125rem;
  color: rgba(235, 235, 235, 0.55);
}

.CharSetup__medCommsBtn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.5rem;
  height: 1.5rem;
  font-size: 0.8125rem;
  color: rgba(121, 134, 203, 0.55);
  background: rgba(121, 134, 203, 0.06);
  border: 0.0625rem solid rgba(121, 134, 203, 0.15);
  border-radius: 0.125rem;
  cursor: pointer;
  transition: all 100ms ease;
  margin: 0 0.0625rem;

  &:hover {
    background: rgba(121, 134, 203, 0.15);
    color: rgba(121, 134, 203, 0.90);
  }
}

.CharSetup__medCommsBtn--danger {
  color: rgba(244, 67, 54, 0.50);
  background: rgba(244, 67, 54, 0.05);
  border-color: rgba(244, 67, 54, 0.12);

  &:hover {
    background: rgba(244, 67, 54, 0.15);
    color: rgba(244, 67, 54, 0.85);
  }
}

.CharSetup__medCommsWarn {
  font-size: 0.875rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(244, 67, 54, 0.75);
  padding: 0.5rem;
  text-align: center;
  border: 0.0625rem dashed rgba(244, 67, 54, 0.25);
  border-radius: 0.1875rem;
  background: rgba(244, 67, 54, 0.04);
}

/* =========================================================
 * AUGMENTATION — Cyberpunk implant interface
 * ========================================================= */

// Main container
.CharSetup__augPanel {
  display: flex;
  flex-direction: column;
  height: 100%;
  gap: 0.5rem;
}

// === TOP HUD BAR ===
.CharSetup__augHud {
  flex-shrink: 0;
  padding: 0.625rem 0.75rem;
  background: rgba(0, 0, 0, 0.20);
  border: 0.0625rem solid rgba(255, 138, 101, 0.15);
  border-radius: 0.375rem;
}

.CharSetup__augHudRow {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.375rem;
}

.CharSetup__augHudLabel {
  flex-shrink: 0;
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: rgba(255, 138, 101, 0.95);
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
}

// Progress bar
.CharSetup__augBarWrap {
  position: relative;
  flex: 1;
  height: 1.25rem;
  background: rgba(0, 0, 0, 0.5);
  border: 0.0625rem solid rgba(255, 138, 101, 0.20);
  border-radius: 0.125rem;
  overflow: hidden;
}

.CharSetup__augBarFill {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  background: linear-gradient(90deg, rgba(255, 138, 101, 0.60), rgba(255, 138, 101, 0.35));
  border-right: 0.125rem solid rgba(255, 138, 101, 0.80);
  transition: width 200ms ease;
}

.CharSetup__augBarFill--over {
  background: linear-gradient(90deg, rgba(244, 67, 54, 0.70), rgba(244, 67, 54, 0.45));
  border-right-color: rgba(244, 67, 54, 0.90);
}

.CharSetup__augBarText {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.875rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(255, 255, 255, 0.90);
  letter-spacing: 0.05em;
}

// Stats row
.CharSetup__augHudStats {
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.06em;
  color: rgba(255, 255, 255, 0.60);
  font-family: var(--cs-font-mono);
  text-transform: uppercase;
}

.CharSetup__augLaceChip {
  cursor: pointer;
  padding: 0.125rem 0.375rem;
  border-radius: 0.125rem;
  background: rgba(255, 138, 101, 0.08);
  border: 0.0625rem solid rgba(255, 138, 101, 0.15);
  transition: background 120ms ease, border-color 120ms ease;

  &:hover {
    background: rgba(255, 138, 101, 0.15);
    border-color: rgba(255, 138, 101, 0.30);
  }
}

// === MAIN BODY: left selector + right detail ===
.CharSetup__augBody {
  flex: 1;
  min-height: 0;
}

// LEFT — Organ selector panel
.CharSetup__augSelector {
  flex: 0 0 11.5rem;
  overflow-y: auto;
  padding-right: 0.375rem;
  border-right: 0.0625rem solid rgba(255, 138, 101, 0.08);
}

.CharSetup__augGroupHeader {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.10em;
  color: rgba(255, 138, 101, 0.85);
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
  padding: 0.3125rem 0.5rem 0.25rem;
  margin-bottom: 0.0625rem;

  border-bottom: 0.0625rem solid rgba(255, 138, 101, 0.08);
}

// Individual organ button
.CharSetup__augOrganBtn {
  display: flex;
  align-items: center;
  gap: 0.4375rem;
  padding: 0.3125rem 0.4375rem;
  border-radius: 0.1875rem;
  cursor: pointer;
  transition: background 100ms ease;
  border-left: 0.125rem solid transparent;

  &:hover {
    background: rgba(255, 255, 255, 0.04);
  }
}

.CharSetup__augOrganBtn--selected {
  background: rgba(255, 138, 101, 0.08);
  border-left-color: rgba(255, 138, 101, 0.70);

  &:hover {
    background: rgba(255, 138, 101, 0.12);
  }
}

.CharSetup__augOrganIcon {
  font-size: 0.875rem;
  width: 1rem;
  text-align: center;
  flex-shrink: 0;
}

.CharSetup__augOrganInfo {
  flex: 1;
  min-width: 0;
}

.CharSetup__augOrganName {
  font-size: 0.875rem;
  font-weight: 600;
  color: rgba(235, 235, 235, 0.92);
  line-height: 1.2;
}

.CharSetup__augOrganStatus {
  font-size: 0.6875rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  font-family: var(--cs-font-mono);
  text-transform: uppercase;
  line-height: 1.2;
}

// Module count badge on organ
.CharSetup__augModBadge {
  flex-shrink: 0;
  min-width: 1.125rem;
  height: 1.125rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.6875rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(255, 255, 255, 0.90);
  background: rgba(255, 138, 101, 0.35);
  border: 0.0625rem solid rgba(255, 138, 101, 0.50);
  border-radius: 0.125rem;
}

// RIGHT — Detail panel
.CharSetup__augDetail {
  overflow-y: auto;
  padding-left: 0.625rem;
}

// Detail header — organ name + status
.CharSetup__augDetailHeader {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 0.625rem;
  margin-bottom: 0.625rem;
  background: rgba(0, 0, 0, 0.25);
  border: 0.0625rem solid rgba(255, 138, 101, 0.12);
  border-radius: 0.25rem;

  // Glowing top edge
}

.CharSetup__augDetailIcon {
  font-size: 1.5rem;
}

.CharSetup__augDetailTitle {
  font-size: 1.125rem;
  font-weight: 700;
  color: rgba(235, 235, 235, 0.95);
  letter-spacing: 0.02em;
}

.CharSetup__augDetailStatus {
  font-size: 0.8125rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  font-family: var(--cs-font-mono);
  text-transform: uppercase;
}

// Section block within detail
.CharSetup__augSection {
  margin-bottom: 0.75rem;
}

.CharSetup__augSectionLabel {
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: rgba(255, 138, 101, 0.80);
  text-transform: uppercase;
  font-family: var(--cs-font-mono);
  padding-bottom: 0.25rem;
  margin-bottom: 0.375rem;
  border-bottom: 0.0625rem solid rgba(255, 138, 101, 0.08);
}

// Status chips (Organic / Amputated / Assisted / Synthetic)
.CharSetup__augChip {
  display: inline-flex;
  align-items: center;
  padding: 0.3125rem 0.625rem;
  margin: 0.125rem;
  border-radius: 0.1875rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  color: rgba(235, 235, 235, 0.70);
  background: rgba(255, 255, 255, 0.03);
  border: 0.0625rem solid rgba(255, 255, 255, 0.08);
  transition: all 120ms ease;

  &:hover {
    background: rgba(255, 255, 255, 0.06);
    color: rgba(235, 235, 235, 0.80);
    border-color: rgba(255, 255, 255, 0.15);
  }
}

.CharSetup__augChip--active {
  color: #6ec87a;
  background: rgba(110, 200, 122, 0.10);
  border-color: rgba(110, 200, 122, 0.30);
}

.CharSetup__augChip--danger {
  color: #f44336;
  background: rgba(244, 67, 54, 0.10);
  border-color: rgba(244, 67, 54, 0.30);
}

.CharSetup__augChip--teal {
  color: #26c6da;
  background: rgba(38, 198, 218, 0.10);
  border-color: rgba(38, 198, 218, 0.30);
}

.CharSetup__augChip--cyber {
  color: #4dc9f6;
  background: rgba(77, 201, 246, 0.10);
  border-color: rgba(77, 201, 246, 0.30);
}

// Brand grid
.CharSetup__augBrandGrid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.375rem;
}

.CharSetup__augBrandCard {
  flex: 0 0 calc(50% - 0.1875rem);
  padding: 0.375rem 0.5rem;
  background: rgba(0, 0, 0, 0.20);
  border: 0.0625rem solid rgba(255, 255, 255, 0.06);
  border-radius: 0.1875rem;
  cursor: pointer;
  transition: all 120ms ease;

  &:hover {
    background: rgba(77, 201, 246, 0.06);
    border-color: rgba(77, 201, 246, 0.18);
  }
}

.CharSetup__augBrandCard--selected {
  background: rgba(77, 201, 246, 0.10);
  border-color: rgba(77, 201, 246, 0.35);
}

.CharSetup__augBrandName {
  font-size: 0.9375rem;
  font-weight: 700;
  color: rgba(235, 235, 235, 0.92);
  letter-spacing: 0.02em;
}

.CharSetup__augBrandDesc {
  font-size: 0.8125rem;
  color: rgba(235, 235, 235, 0.65);
  line-height: 1.35;
  margin-top: 0.125rem;
}

// === MODULE CARDS ===
.CharSetup__augModCard {
  padding: 0.5rem 0.625rem;
  margin-bottom: 0.25rem;
  background: rgba(0, 0, 0, 0.18);
  border: 0.0625rem solid rgba(255, 255, 255, 0.05);
  border-left: 0.1875rem solid rgba(255, 255, 255, 0.08);
  border-radius: 0.1875rem;
  cursor: pointer;
  transition: all 120ms ease;

  &:hover {
    background: rgba(255, 138, 101, 0.05);
    border-left-color: rgba(255, 138, 101, 0.30);
  }
}

.CharSetup__augModCard--installed {
  background: rgba(110, 200, 122, 0.06);
  border-left-color: rgba(110, 200, 122, 0.60);

  &:hover {
    background: rgba(110, 200, 122, 0.10);
    border-left-color: rgba(110, 200, 122, 0.80);
  }
}

.CharSetup__augModToggle {
  font-size: 1.125rem;
  width: 1.375rem;
  text-align: center;
  color: rgba(255, 255, 255, 0.20);
  transition: color 120ms ease;
}

.CharSetup__augModToggle--on {
  color: #6ec87a;
  filter: drop-shadow(0 0 0.25rem rgba(110, 200, 122, 0.40));
}

.CharSetup__augModName {
  font-size: 1.0625rem;
  font-weight: 700;
  color: rgba(235, 235, 235, 0.95);
  letter-spacing: 0.01em;
}

.CharSetup__augModType {
  display: inline-block;
  margin-left: 0.375rem;
  padding: 0.0625rem 0.375rem;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  font-family: var(--cs-font-mono);
  color: rgba(77, 201, 246, 0.85);
  background: rgba(77, 201, 246, 0.12);
  border: 0.0625rem solid rgba(77, 201, 246, 0.25);
  border-radius: 0.125rem;
  vertical-align: middle;
}

.CharSetup__augModDesc {
  font-size: 0.9375rem;
  color: rgba(235, 235, 235, 0.68);
  line-height: 1.4;
  margin-top: 0.1875rem;
}

.CharSetup__augModRoles {
  font-size: 0.8125rem;
  color: rgba(255, 193, 7, 0.80);
  font-family: var(--cs-font-mono);
  margin-top: 0.1875rem;
}

.CharSetup__augModCost {
  font-size: 0.9375rem;
  font-weight: 700;
  font-family: var(--cs-font-mono);
  color: rgba(255, 138, 101, 0.92);
  text-align: right;
  letter-spacing: 0.04em;
}

.CharSetup__augModCpu {
  font-size: 0.8125rem;
  font-family: var(--cs-font-mono);
  color: rgba(77, 201, 246, 0.80);
  text-align: right;
  margin-top: 0.125rem;
}

// Pulsing animation for over-budget bar
@keyframes augBarPulse {
  0%, 100% { opacity: 0.85; }
  50%      { opacity: 1; }
}

/* =========================================================
 * CAREER — Department boxes and job rows
 * ========================================================= */

.CharSetup__deptBox {
  background: rgba(255, 255, 255, 0.02);
  border-radius: 0.25rem;
}

.CharSetup__deptHeader {
  padding: 0.375rem 0.625rem;
  font-size: 0.75rem;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.CharSetup__jobRow {
  display: flex;
  align-items: center;
  padding: 0.25rem 0.5rem;
  gap: 0.5rem;

  &:nth-child(even) {
    background: rgba(255, 255, 255, 0.02);
  }

  &--head {
    background-color: var(--dept-color-bg) !important;
  }
}

.CharSetup__jobName {
  flex: 1 1 0;
  min-width: 0;

  /* Let the inline dropdown fill naturally */
  .Dropdown {
    display: block;
  }

  .Dropdown__control {
    min-width: 0;
    width: 100%;
  }
}

.CharSetup__jobList {
  column-count: 2;
  column-gap: 0.5rem;

  .CharSetup__deptBox {
    break-inside: avoid;
  }
}

.CharSetup__jobPriority {
  flex-shrink: 0;

  .CharSetup__btn {
    width: 4.5rem;
    text-align: center;
    justify-content: center;
  }
}

/* =========================================================
 * SCROLLBAR — dark sci-fi themed (IE/BYOND scrollbar props)
 * ========================================================= */

.CharSetup,
.CharSetup * {
  scrollbar-base-color: #111113;
  scrollbar-face-color: #3a3a42;
  scrollbar-3dlight-color: #252528;
  scrollbar-highlight-color: #3a3a42;
  scrollbar-track-color: #0c0c0e;
  scrollbar-arrow-color: #7a8090;
  scrollbar-shadow-color: #0a0a0c;

  &::-webkit-scrollbar {
    width: 0.375rem;
    height: 0.375rem;
  }

  &::-webkit-scrollbar-track {
    background: rgba(8, 8, 10, 0.60);
    border-radius: 0.25rem;
  }

  &::-webkit-scrollbar-thumb {
    background: rgba(80, 80, 95, 0.55);
    border-radius: 0.25rem;

    &:hover {
      background: rgba(100, 100, 120, 0.70);
    }

    &:active {
      background: rgba(130, 145, 168, 0.75);
    }
  }

  &::-webkit-scrollbar-corner {
    background: transparent;
  }
}

// Augmentation panel uses orange-accented scrollbar
.CharSetup__augSelector,
.CharSetup__augDetail {
  scrollbar-base-color: #0c0e10;
  scrollbar-face-color: #3a2820;
  scrollbar-3dlight-color: #2a1c14;
  scrollbar-highlight-color: #4a3428;
  scrollbar-track-color: #080808;
  scrollbar-arrow-color: #c07040;
  scrollbar-shadow-color: #060606;

  &::-webkit-scrollbar-track {
    background: rgba(8, 5, 3, 0.65);
  }

  &::-webkit-scrollbar-thumb {
    background: rgba(100, 55, 25, 0.55);

    &:hover {
      background: rgba(192, 112, 64, 0.70);
    }

    &:active {
      background: rgba(220, 140, 90, 0.80);
    }
  }
}

/* =========================================================
 * SearchDropdown — combined search input + dropdown
 * ========================================================= */

.SearchDropdown {
  position: relative;
  display: inline-block;
}

.SearchDropdown__inputWrap {
  position: relative;
  display: flex;
  align-items: center;
  background: rgba(0, 0, 0, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 0.25rem;
  height: 1.5rem;
  overflow: hidden;
}

.SearchDropdown__input {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 100%;
  padding: 0 1.5rem 0 0.375rem;
  background: transparent;
  border: none;
  outline: none;
  color: #dde4f0;
  font-family: Verdana, sans-serif;
  font-size: 0.75rem;

  &::placeholder {
    color: #dde4f0;
    opacity: 1;
  }

  &:focus::placeholder {
    color: rgba(255, 255, 255, 0.3);
    opacity: 1;
  }
}

.SearchDropdown__chevron {
  position: absolute;
  right: 0.375rem;
  top: 50%;
  transform: translateY(-50%);
  color: rgba(255, 255, 255, 0.5);
  font-size: 0.625rem;
  pointer-events: none;
}

.SearchDropdown__list {
  position: absolute;
  z-index: 10;
  left: 0;
  right: 0;
  top: 100%;
  max-height: 12rem;
  overflow-y: auto;
  background: #1a1c22;
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 0 0 0.25rem 0.25rem;
}

.SearchDropdown__option {
  padding: 0.2rem 0.375rem;
  font-family: Verdana, sans-serif;
  font-size: 0.75rem;
  color: #dde4f0;
  cursor: pointer;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  &--selected {
    background: #2a3a5a;
    color: #e8f0ff;
  }
}

/* =========================================================
 * Languages compact — row-based list for ID card back
 * ========================================================= */

.CharSetup__langRow {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  margin-bottom: 0.25rem;
  padding: 0.125rem 0;
}

.CharSetup__langIcon {
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.45);
  width: 0.875rem;
  text-align: center;
  flex-shrink: 0;

  &--native {
    color: #6dba5e;
  }

  &--alt {
    color: #5b9bd5;
  }
}

.CharSetup__langName {
  flex: 1;
  font-size: 1rem;
  color: #dde4f0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.CharSetup__langTag {
  font-size: 0.6875rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 0.0625rem 0.3rem;
  border-radius: 0.1875rem;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.45);
  flex-shrink: 0;

  &--native {
    background: rgba(109, 186, 94, 0.15);
    color: #6dba5e;
  }
}

```

`packages\tgui\styles\interfaces\ColorPicker.scss`

```scss
/**
 * MIT License
 * https://github.com/omgovich/react-colorful/
 *
 * Copyright (c) 2020 Vlad Shilov <omgovich@ya.ru>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

@use "../colors.scss";
@use "../base.scss";

.react-colorful {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 200px;
  height: 200px;
  user-select: none;
  cursor: default;
}

.react-colorful__saturation_value {
  position: relative;
  flex-grow: 1;
  border-color: transparent; /* Fixes https://github.com/omgovich/react-colorful/issues/139 */
  border-bottom: 12px solid #000;
  border-radius: 8px 8px 0 0;
  background-image: linear-gradient(
      to top,
      rgba(0, 0, 0, 255),
      rgba(0, 0, 0, 0)
    ),
    linear-gradient(to right, rgba(255, 255, 255, 255), rgba(255, 255, 255, 0));
}

.react-colorful__pointer-fill,
.react-colorful__alpha-gradient {
  content: "";
  position: absolute;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  border-radius: inherit;
}

/* Improve elements rendering on light backgrounds */
.react-colorful__alpha-gradient,
.react-colorful__saturation_value {
  box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05);
}

.react-colorful__hue,
.react-colorful__r,
.react-colorful__g,
.react-colorful__b,
.react-colorful__alpha,
.react-colorful__saturation,
.react-colorful__value {
  position: relative;
  height: 24px;
}

.react-colorful__hue {
  background: linear-gradient(
    to right,
    #f00 0%,
    #ff0 17%,
    #0f0 33%,
    #0ff 50%,
    #00f 67%,
    #f0f 83%,
    #f00 100%
  );
}

.react-colorful__r {
  background: linear-gradient(to right, #000, #f00);
}

.react-colorful__g {
  background: linear-gradient(to right, #000, #0f0);
}

.react-colorful__b {
  background: linear-gradient(to right, #000, #00f);
}

/* Round bottom corners of the last element: `Hue` for `ColorPicker` or `Alpha` for `AlphaColorPicker` */
.react-colorful__last-control {
  border-radius: 0 0 8px 8px;
}

.react-colorful__interactive {
  position: absolute;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  border-radius: inherit;
  outline: none;
  /* Don't trigger the default scrolling behavior when the event is originating from this element */
  touch-action: none;
}

.react-colorful__pointer {
  position: absolute;
  z-index: 1;
  box-sizing: border-box;
  width: 28px;
  height: 28px;
  transform: translate(-50%, -50%);
  background-color: #cfcfcf;
  border: 2px solid #cfcfcf;
  border-radius: 50%;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.4);
}

.react-colorful__interactive:focus .react-colorful__pointer {
  transform: translate(-50%, -50%) scale(1.1);
  background-color: #fff;
  border-color: #fff;
}

/* Chessboard-like pattern for alpha related elements */
.react-colorful__alpha,
.react-colorful__alpha-pointer {
  background-color: #fff;
  background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill-opacity=".05"><rect x="8" width="8" height="8"/><rect y="8" width="8" height="8"/></svg>');
}

.react-colorful__saturation-pointer,
.react-colorful__value-pointer,
.react-colorful__hue-pointer,
.react-colorful__r-pointer,
.react-colorful__g-pointer,
.react-colorful__b-pointer {
  z-index: 1;
  width: 20px;
  height: 20px;
}

/* Display the saturation value pointer over the hue one */
.react-colorful__saturation_value-pointer {
  z-index: 3;
}

```

`packages\tgui\styles\interfaces\EventsPanel.scss`

```scss
@use '../colors.scss';

.ConditionsDescription em {
	font-style: normal;
	color: colors.fg(colors.$blue);
	font-weight: bold;
}

```

`packages\tgui\styles\interfaces\FloorPainter.scss`

```scss
.FloorPainter {
  &__Button {
    cursor: pointer;
    background-color: rgba(255, 255, 255, 0.05);

    &:hover,
    &:focus {
      background-color: rgba(255, 255, 255, 0.3);
    }

    &.Button--selected {
      background-color: rgba(0, 255, 42, 0.3);
    }

    &.Button--disabled {
      cursor: default;
      background-color: rgba(255, 255, 255, 0.6) !important;
    }
  }
}

```

`packages\tgui\styles\interfaces\ListInput.scss`

```scss
/**
 * Copyright (c) 2020 bobbahbrown (https://github.com/bobbahbrown)
 * SPDX-License-Identifier: MIT
 */

 @use '../colors.scss';
 @use '../base.scss';


.ListInput__Section .Section__title{
  flex-shrink: 0;
}

.ListInput__Section .Section__titleText {
  font-size: base.em(12px);
}

 .ListInput__Loader {
   width: 100%;
   position: relative;
   height: 4px;
 }

 .ListInput__LoaderProgress {
   position: absolute;
   transition: background-color 500ms ease-out, width 500ms ease-out;
   background-color: colors.bg(colors.$primary);
   height: 100%;
 }

```

`packages\tgui\styles\interfaces\MechaFabricator.scss`

```scss
.MechaFabricator {
  &__slideAnimation {
    animation: slide-up 0.4s ease;
  }

  @keyframes slide-up {
    0% {
      opacity: 0;
      transform: translateY(100vh);
    }
    100% {
      opacity: 1;
      transform: translateY(0);
    }
  }
}

.Storage .game-icon {
  @at-root .theme-primer-white &, .theme-primer-dark & {
    width: 3em;
    height: 3em;
    vertical-align: -1.5rem;
  }
}

.Buildable .game-icon {
  @at-root .theme-primer-white &, .theme-primer-dark & {
    width: 2em;
    height: 2em;
    vertical-align: -1.5rem;
  }
}

```

`packages\tgui\styles\interfaces\Minesweeper.scss`

```scss
.Minesweeper__Button {
  font-size: 22px;
  font-weight: bold;
  border: 5px solid #404040;
  border-left-color: #808080;
  border-top-color: #808080;
  margin: 0px;
  vertical-align: top;
  width: 30px;
  height: 30px;
  border-radius: 0px;
  padding-left: 2px;
  background-color: #5f5f5f !important;
  &:hover {
    background-color: #4b4b4b !important;
    border: 5px solid #707070;
    border-left-color: #3c3c3c;
    border-top-color: #3c3c3c;
    .Minesweeper__Button-Content {
      zoom: 90%;
      top: -7px !important;
      left: 1px;
    }
  }
  .Minesweeper__Button-Content {
    position: relative;
    top: -8px;
    transform: scale(0.75, 0.75);
  }
}

.Minesweeper__Button.Button--disabled {
  border: 2px solid #2f2f2f;
  padding-left: 5px;
  background-color: #4b4b4b !important;
  &:hover {
    .Minesweeper__Button-Content {
      zoom: 100%;
      top: -6px !important;
      left: 0px !important;
    }
  }
  .Minesweeper__Button-Content {
    top: -6px;
    transform: scale(1, 1);
  }
}

```

`packages\tgui\styles\interfaces\NuclearBomb.scss`

```scss
@use "../base.scss";
@use "../colors.scss";
@use "../functions.scss" as *;

$color-danger: colors.bg(colors.$red) !default;
$color-caution: colors.bg(colors.$yellow) !default;

$background-beige: #e8e4c9;

.NuclearBomb__displayBox {
  background-color: #002003;
  border: 0.167em inset $background-beige;
  color: #03e017;
  font-size: 2em;
  font-family: monospace;
  padding: 0.25em;
}

.NuclearBomb__Button {
  outline-width: 0.25rem !important;
  border-width: 0.65rem !important;
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.NuclearBomb__Button--keypad {
  background-color: $background-beige;
  border-color: $background-beige;
  &:hover {
    background-color: lighten($background-beige, 15%) !important;
    border-color: lighten($background-beige, 15%) !important;
  }
}

.NuclearBomb__Button--1 {
  background-color: #d3cfb7 !important;
  border-color: #d3cfb7 !important;
  color: #a9a692 !important;
}

.NuclearBomb__Button--E {
  background-color: $color-caution !important;
  border-color: $color-caution !important;
  &:hover {
    background-color: lighten($color-caution, 15%) !important;
    border-color: lighten($color-caution, 15%) !important;
  }
}

.NuclearBomb__Button--C {
  background-color: $color-danger !important;
  border-color: $color-danger !important;
  &:hover {
    background-color: lighten($color-danger, 15%) !important;
    border-color: lighten($color-danger, 15%) !important;
  }
}

.NuclearBomb__NTIcon {
  background-image: url("../assets/bg-nanotrasen.svg");
  background-size: 70%;
  background-position: center;
  background-repeat: no-repeat;
}

```

`packages\tgui\styles\interfaces\PencodeEditorModal.scss`

```scss
.PencodeEditorModal {
  height: 100%;
}

.PencodeEditorModal__body {
  flex: 1 1 auto;
  min-height: 0;
}
.PencodeEditorModal {
  height: 100%;
  position: relative;
  isolation: isolate; /* ВАЖНО: отдельный stacking context для всей модалки */
}

/* Шапка и тулбар всегда кликабельны поверх любых transform-слоёв редактора */
.PencodeEditorModal__topbar,
.PencodeEditorModal__toolbar {
  position: relative;
  z-index: 1000;
}

/* Тело ниже шапки */
.PencodeEditorModal__body {
  position: relative;
  z-index: 1;
  overflow: hidden; /* чтобы внутренние абсолютные слои не “выпрыгивали” */
}

/* Редактор в своём локальном контексте, ниже шапки */
.PencodeEditorModal__editorWrap {
  position: relative;
  z-index: 0;
  overflow: hidden; /* на всякий случай для хитбокса при скролле */
}
/* Ключевой фикс "textarea не раздувает окно":
   делаем внутренний layout flex-column и разрешаем body сжиматься */
.PencodeEditorModal__layout {
  height: 100%;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

/* Шапка и тулбар всегда выше любых слоёв редактора */
.PencodeEditorModal__topbar,
.PencodeEditorModal__toolbar {
  position: relative;
  z-index: 50;
}

/* Тело ниже шапки */
.PencodeEditorModal__body {
  position: relative;
  z-index: 1;
}

/* ВАЖНО: создаём локальный stacking context для редактора,
   чтобы transform внутри не мог “выпрыгнуть” над шапку */
.PencodeEditorModal__editorWrap {
  position: relative;
  z-index: 0;
  overflow: hidden; /* фикс на случай артефактов хитбокса при скролле */
}


.PencodeEditorModal__topbar {
  margin-bottom: 6px;
  padding: 6px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  background: rgba(0, 0, 0, 0.10);
}

.PencodeEditorModal__topbarRow {
  gap: 6px;
}

.PencodeEditorModal__message {
  margin-top: 4px;
  opacity: 0.85;
}

.PencodeEditorModal__counter {
  padding: 2px 6px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 2px;
  background: rgba(0, 0, 0, 0.14);
  font-size: 12px;
  white-space: nowrap;
}

.PencodeEditorModal__counter--bad {
  border-color: rgba(255, 80, 80, 0.35);
  background: rgba(255, 80, 80, 0.10);
}

.PencodeEditorModal__toolbar {
  margin-bottom: 8px;
  padding: 6px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  background: rgba(0, 0, 0, 0.10);
}

.PencodeEditorModal__toolbarRow {
  gap: 4px;
  align-items: center;
}

/* Scoped alignment for icons */
.PencodeEditorModal .Button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.PencodeEditorModal .Button .Icon,
.PencodeEditorModal .Button i {
  line-height: 1;
  vertical-align: middle;
}

.PencodeEditorModal__btn {
  height: 24px;
  min-width: 28px;
  padding: 0 6px;
  font-size: 12px;
  line-height: 22px;
}

.PencodeEditorModal__btnWide {
  height: 24px;
  min-width: 92px;
}

/* editor */
.PencodeEditorModal__previewWrap,
.PencodeEditorModal__editorWrap {
  position: relative;
  height: 100%;
  min-height: 0; /* важно */
  background: #ffffff;
  border: 1px solid rgba(0, 0, 0, 0.25);
  border-radius: 2px;
}


/* highlight layer - ПОД textarea, БЕЗ собственного скролла */
.PencodeEditorModal__highlight {
  position: absolute;

  top: 0;
  left: 0;
  right: var(--pencode-sbw, 0px);
  bottom: var(--pencode-sbh, 0px);

  overflow: hidden;
  pointer-events: none;
  z-index: 1;
  background: transparent;
}

/* контент подсветки, который мы будем сдвигать transform'ом */
.PencodeEditorModal__highlightContent {
  padding: 8px;
  box-sizing: border-box;

  font: inherit;
  line-height: 1.3;
  white-space: pre-wrap;
  word-break: break-word;

  color: #000000;

  will-change: transform;
}

/* textarea - НАД highlight */
.PencodeEditorModal__textarea {
  position: relative;
  z-index: 2;

  width: 100%;
  height: 100%;
  resize: none;
  box-sizing: border-box;
  padding: 8px;
  font: inherit;
  line-height: 1.3;

  /* фон/рамка убраны — они у editorWrap */
  background: transparent;
  border: 0;
  outline: none;

  color: #000000;
}

/* syntax: делаем текст почти прозрачным, но caret/selection остаются */
.PencodeEditorModal__textarea--syntax {
  color: rgba(0, 0, 0, 0.02);
  -webkit-text-fill-color: rgba(0, 0, 0, 0.02);
  caret-color: #000000;
}

/* выделение */
.PencodeEditorModal__textarea--syntax::selection {
  background: rgba(0, 120, 215, 0.35);
}

/* выключение overlay */
.PencodeEditorModal__highlight--off {
  visibility: hidden;
}

/* highlight colors */
.PencodeEditorModal__tok--open { color: #0066cc; }
.PencodeEditorModal__tok--close { color: #cc5500; }
.PencodeEditorModal__tok--star { color: #1a7f37; }

/* ===========================
   Preview (paper-like, input-like)
   =========================== */

/* Обёртка превью должна скроллиться как textarea */
.PencodeEditorModal__previewWrap {
  position: relative;
  height: 100%;
  min-height: 0;

  overflow: auto; /* КЛЮЧ: скролл */

  /* В теме общий цвет текста часто белый — прибиваем к “бумаге” */
  color: #000;

  /* на всякий: не даём теме делать полупрозрачность */
  opacity: 1;
}

/* Сам контейнер HTML: без внутренней “тёмной панели” */
.PencodeEditorModal__preview {
  box-sizing: border-box;
  padding: 8px;

  border: 0;
  background: transparent;

  /* КЛЮЧ: метрики как у ввода */
  font: inherit;
  line-height: 1.3;

  /* КЛЮЧ: фикс “видно только при выделении” */
  color: #000;
  opacity: 1;
  text-shadow: none;
  -webkit-text-fill-color: #000; /* Safari/Chromium: иногда тема ломает fill */

  word-break: break-word;
}

/* Часто проблема именно в том, что тема накладывает “прозрачный текст” на потомков.
   Это НЕ должно ломать inline-цвета (font color / span style), т.к. inline сильнее. */
.PencodeEditorModal__preview * {
  opacity: 1;
  text-shadow: none;
  -webkit-text-fill-color: currentColor;
}

/* Картинки/таблицы не должны вылезать за ширину */
.PencodeEditorModal__preview img,
.PencodeEditorModal__preview table {
  max-width: 100%;
}

/* ===========================
   Paper-like bits (scoped)
   =========================== */

/* Таблицы: ближе к DM (там нет collapse), но без “дыр” */
.PencodeEditorModal__preview table {
  border: 1px solid #000;

  border-collapse: separate; /* важно: не collapse */
  border-spacing: 0;         /* если хотите “классический зазор” — поставьте 2px */
}

.PencodeEditorModal__preview th,
.PencodeEditorModal__preview td {
  border: 1px solid #000;
  padding: 2px 4px;
  vertical-align: top;
}

/* Размерные классы как в paper.styles */
.PencodeEditorModal__preview .SmallFont { font-size: 0.7em; }
.PencodeEditorModal__preview .MediumFont { font-size: 1.2em; }
.PencodeEditorModal__preview .LargeFont { font-size: 1.3em; }

/* Если прилетает Handwritten — пусть выглядит отличимо, но без обязательных ассетов */
.PencodeEditorModal__preview .Handwritten {
  font-family: "Segoe Script", "Comic Sans MS", cursive;
}

.PencodeEditorModal__preview hr.Handwritten {
		border: none;
		height: 5px;
		background-image: url('../assets/line_hand.png');
		background-repeat: repeat-x;
		background-size: contain;
	}

.PencodeEditorModal__preview table.Handwritten,
.PencodeEditorModal__preview th.Handwritten,
.PencodeEditorModal__preview td.Handwritten {
		border: 5px solid black;
		border-image: url('../assets/borders_hand.png') 27 fill;
		border-image-width: 10px;
	}

```

`packages\tgui\styles\interfaces\WordProcessor.scss`

```scss
.WordProcessor {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  isolation: isolate;
}

.WordProcessor__windowContent {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

/* ===== Topbar (PC header) ===== */

.WordProcessor__topbar {
  flex: 0 0 auto;
  margin-bottom: 6px;
  padding: 6px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  background: rgba(0, 0, 0, 0.10);
}

.WordProcessor__topbarLeft,
.WordProcessor__topbarRight {
  display: flex;
  align-items: center;
  gap: 6px;
}

.WordProcessor__hdrIcon {
  width: 40px;
  height: 22px;
  vertical-align: middle;
}

.WordProcessor__counter {
  padding: 2px 6px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 2px;
  background: rgba(0, 0, 0, 0.14);
  font-size: 12px;
  white-space: nowrap;
}

/* ===== Main section layout ===== */

.WordProcessor__main {
  flex: 1 1 auto;
  min-height: 0; /* КЛЮЧ */
  display: flex;
  flex-direction: column;
}

/* Section внутри WordProcessor должен уметь растягиваться по высоте */
.WordProcessor__content {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.WordProcessor__content .Section__content,
.WordProcessor__content .Section__body,
.WordProcessor__content .Section__content > *,
.WordProcessor__content .Section__body > * {
  min-height: 0;
}

.WordProcessor__content .Section__content,
.WordProcessor__content .Section__body {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
}

/* ===== Document toolbar (в строке заголовка Section) ===== */

.WordProcessor__docBar {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: nowrap;
  min-width: 0;
}

.WordProcessor__btn {
  height: 22px;
  min-width: 26px;
  padding: 0 6px;
  font-size: 12px;
  line-height: 20px;
}

.WordProcessor__btnWide {
  height: 22px;
  padding: 0 8px;
  font-size: 12px;
  line-height: 20px;
  white-space: nowrap;
}

.WordProcessor__docBarScroll {
  overflow-x: auto;
  overflow-y: hidden;
  white-space: nowrap;
  padding-bottom: 1px;
  max-width: 100%;
}

/* ===== Editor columns ===== */

.WordProcessor__cols {
  flex: 1 1 auto;
  min-height: 0; /* КЛЮЧ */
}

.WordProcessor__sidebar {
  min-height: 0;
}

.WordProcessor__rightCol {
  min-height: 0;
}

/* ===== Pages panel ===== */

.WordProcessor__pagesHeader {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
  margin-bottom: 6px;
}

.WordProcessor__pager {
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
}

.WordProcessor__pagerText {
  padding: 2px 6px;
  border: 1px solid rgba(255, 255, 255, 0.10);
  border-radius: 2px;
  background: rgba(0, 0, 0, 0.14);
  font-size: 12px;
}

.WordProcessor__pageActions {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: nowrap;
}

/* Сетка страниц: под кнопки 32x32 */
.WordProcessor__pagesGrid {
  display: grid;
  grid-template-columns: repeat(6, 32px);
  gap: 4px;
  justify-content: start;
}

.WordProcessor__pageNumBtn {
  width: 32px;
  height: 32px;
  min-width: 0;
  padding-top: 5px;
  justify-content: center;
  text-align: center;
  line-height: 24px;
}

/* ===== Preview: фикс высоты/границ ===== */

/* ВАЖНО: эта обёртка должна занять всю высоту Section content */
.WordProcessor__rightFill {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

/* тело справа тянется */
.WordProcessor__rightBody {
  flex: 1 1 auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

/* preview растягивается даже при пустом контенте */
.WordProcessor__previewWrap {
  position: relative;
  flex: 1 1 0;
  min-height: 0;

  overflow: auto;

  background: #ffffff;
  border: 1px solid rgba(0, 0, 0, 0.25);
  border-radius: 2px;

  color: #000;
  opacity: 1;
}

.WordProcessor__preview {
  box-sizing: border-box;
  padding: 8px;

  border: 0;
  background: transparent;

  font: inherit;
  line-height: 1.3;

  color: #000;
  opacity: 1;
  text-shadow: none;
  -webkit-text-fill-color: #000;

  word-break: break-word;

  /* чтобы пустая страница не схлопывала контент визуально */
  min-height: 100%;
}

.WordProcessor__preview * {
  opacity: 1;
  text-shadow: none;
  -webkit-text-fill-color: currentColor;
}

.WordProcessor__preview img,
.WordProcessor__preview table {
  max-width: 100%;
}

/* Таблицы ближе к DM */
.WordProcessor__preview table {
  border: 1px solid #000;
  border-collapse: separate;
  border-spacing: 0;
}

.WordProcessor__preview th,
.WordProcessor__preview td {
  border: 1px solid #000;
  padding: 2px 4px;
  vertical-align: top;
}

.WordProcessor__preview .SmallFont { font-size: 0.7em; }
.WordProcessor__preview .MediumFont { font-size: 1.2em; }
.WordProcessor__preview .LargeFont { font-size: 1.3em; }

```

`packages\tgui\styles\layouts\Layout.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use '../base.scss';

$scrollbar-color-multiplier: 1 !default;

.Layout,
.Layout * {
  // Fancy scrollbar
  scrollbar-base-color: color.scale(
    base.$color-bg,
    $lightness: -25% * $scrollbar-color-multiplier
  );
  scrollbar-face-color: color.scale(
    base.$color-bg,
    $lightness: 10% * $scrollbar-color-multiplier
  );
  scrollbar-3dlight-color: color.scale(
    base.$color-bg,
    $lightness: 0% * $scrollbar-color-multiplier
  );
  scrollbar-highlight-color: color.scale(
    base.$color-bg,
    $lightness: 0% * $scrollbar-color-multiplier
  );
  scrollbar-track-color: color.scale(
    base.$color-bg,
    $lightness: -25% * $scrollbar-color-multiplier
  );
  scrollbar-arrow-color: color.scale(
    base.$color-bg,
    $lightness: 50% * $scrollbar-color-multiplier
  );
  scrollbar-shadow-color: color.scale(
    base.$color-bg,
    $lightness: 10% * $scrollbar-color-multiplier
  );
}

.Layout__content {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  overflow-x: hidden;
  overflow-y: hidden;
}

.Layout__content--scrollable {
  overflow-y: scroll;
  margin-bottom: 0;
}

```

`packages\tgui\styles\layouts\TitleBar.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use '../base.scss';
@use '../colors.scss';

$text-color: rgba(255, 255, 255, 0.75) !default;
$background-color: #363636 !default;
$shadow-color-core: #161616 !default;
$shadow-color: rgba(0, 0, 0, 0.1) !default;

.TitleBar {
  background-color: $background-color;
  border-bottom: 1px solid $shadow-color-core;
  box-shadow: 0 2px 2px $shadow-color;
  box-shadow: 0 base.rem(2px) base.rem(2px) $shadow-color;
  user-select: none;
  -ms-user-select: none;
}

.TitleBar__clickable {
  color: color.change($text-color, $alpha: 0.5);
  background-color: $background-color;
  transition: color 250ms ease-out, background-color 250ms ease-out;

  &:hover {
    color: rgba(255, 255, 255, 1);
    background-color: #cc0000;
    transition: color 0ms, background-color 0ms;
  }
}

.TitleBar__title {
  position: absolute;
  top: 0;
  left: 46px;
  left: base.rem(46px);
  color: $text-color;
  font-size: 14px;
  font-size: base.rem(14px);
  line-height: 31px;
  line-height: base.rem(31px);
  white-space: nowrap;
}

.TitleBar__dragZone {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 32px;
  height: base.rem(32px);
}

.TitleBar__statusIcon {
  position: absolute;
  top: 0;
  left: 12px;
  left: base.rem(12px);
  transition: color 0.5s;
  font-size: 20px;
  font-size: base.rem(20px);
  line-height: 32px !important;
  line-height: base.rem(32px) !important;
}

.TitleBar__close {
  position: absolute;
  top: -1px;
  right: 0;
  width: 45px;
  width: base.rem(45px);
  height: 32px;
  height: base.rem(32px);
  font-size: 20px;
  font-size: base.rem(20px);
  line-height: 31px;
  line-height: base.rem(31px);
  text-align: center;
}

.TitleBar__devBuildIndicator {
  position: absolute;
  top: 6px;
  top: base.rem(6px);
  right: 52px;
  right: base.rem(52px);
  min-width: 20px;
  min-width: base.rem(20px);
  padding: 2px 4px;
  padding: base.rem(2px) base.rem(4px);
  background-color: rgba(colors.$good, 0.75);
  color: #fff;
  text-align: center;
}

```

`packages\tgui\styles\layouts\Window.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use 'sass:color';
@use '../base.scss';
@use '../functions.scss' as *;

.Window {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  color: base.$color-fg;
  background-color: base.$color-bg;
  background-image: linear-gradient(
    to bottom,
    base.$color-bg-start 0%,
    base.$color-bg-end 100%
  );
}

.Window__titleBar {
  position: fixed;
  z-index: 1;
  top: 0;
  left: 0;
  width: 100%;
  height: 32px;
  height: base.rem(32px);
}

// Everything after the title bar
.Window__rest {
  position: fixed;
  top: 32px;
  top: base.rem(32px);
  bottom: 0;
  left: 0;
  right: 0;
}

.Window__contentPadding {
  margin: 0.5rem;
  // IE8: Calc not supported
  height: 100%;
  // 0.01 is needed to make the scrollbar not appear
  // due to rem rendering inaccuracies in IE11.
  height: calc(100% - 1.01rem);
}

.Window__contentPadding:after {
  height: 0;
}

.Layout__content--scrollable .Window__contentPadding:after {
  display: block;
  content: '';
  height: 0.5rem;
}

.Window__dimmer {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: rgba(lighten(base.$color-bg, 30%), 0.25);
  pointer-events: none;
}

.Window__resizeHandle__se {
  position: fixed;
  bottom: 0;
  right: 0;
  width: 20px;
  width: base.rem(20px);
  height: 20px;
  height: base.rem(20px);
  cursor: se-resize;
}

.Window__resizeHandle__s {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 6px;
  height: base.rem(6px);
  cursor: s-resize;
}

.Window__resizeHandle__e {
  position: fixed;
  top: 0;
  bottom: 0;
  right: 0;
  width: 3px;
  width: base.rem(3px);
  cursor: e-resize;
}

```

`packages\tgui\styles\main.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use "sass:meta";
@use "sass:math";
@use "./base.scss";

// Core styles
@include meta.load-css("./reset.scss");

// Atomic classes
@include meta.load-css("./atomic/candystripe.scss");
@include meta.load-css("./atomic/color.scss");
@include meta.load-css("./atomic/debug-layout.scss");
@include meta.load-css("./atomic/links.scss");
@include meta.load-css("./atomic/outline.scss");
@include meta.load-css("./atomic/text.scss");

// Components
@include meta.load-css("./components/BlockQuote.scss");
@include meta.load-css("./components/Button.scss");
@include meta.load-css("./components/ColorBox.scss");
@include meta.load-css("./components/Dimmer.scss");
@include meta.load-css("./components/Divider.scss");
@include meta.load-css("./components/Dropdown.scss");
@include meta.load-css("./components/Flex.scss");
@include meta.load-css("./components/Icon.scss");
@include meta.load-css("./components/Input.scss");
@include meta.load-css("./components/Knob.scss");
@include meta.load-css("./components/LabeledList.scss");
@include meta.load-css("./components/Modal.scss");
@include meta.load-css("./components/NoticeBox.scss");
@include meta.load-css("./components/NumberInput.scss");
@include meta.load-css("./components/ProgressBar.scss");
@include meta.load-css("./components/RoundGauge.scss");
@include meta.load-css("./components/Section.scss");
@include meta.load-css("./components/Slider.scss");
@include meta.load-css("./components/Stack.scss");
@include meta.load-css("./components/Table.scss");
@include meta.load-css("./components/Tabs.scss");
@include meta.load-css("./components/TextArea.scss");
@include meta.load-css("./components/Tooltip.scss");
@include meta.load-css("./components/Seg7.scss");
@include meta.load-css("./components/FlatGauge.scss");
@include meta.load-css("./components/RockerSwitch.scss");
@include meta.load-css("./components/ThermoSlider.scss");


// Interfaces
@include meta.load-css("./interfaces/ColorPicker.scss");
@include meta.load-css("./interfaces/ListInput.scss");
@include meta.load-css("./interfaces/MechaFabricator.scss");
@include meta.load-css("./interfaces/FloorPainter.scss");
@include meta.load-css("./interfaces/EventsPanel.scss");
@include meta.load-css("./interfaces/NuclearBomb.scss");
@include meta.load-css("./interfaces/Minesweeper.scss");
@include meta.load-css("./interfaces/PencodeEditorModal.scss");
@include meta.load-css("./interfaces/AirAlarm.scss");
@include meta.load-css("./interfaces/CharacterSetup.scss");
@include meta.load-css("./interfaces/WordProcessor.scss");

// Layouts
@include meta.load-css("./layouts/Layout.scss");
@include meta.load-css("./layouts/TitleBar.scss");
@include meta.load-css("./layouts/Window.scss");

.flex-gap-4 > * + * { margin-left: 4px; }
.flex-gap-6 > * + * { margin-left: 6px; }
.flex-gap-8 > * + * { margin-left: 8px; }
.flex-gap-10 > * + * { margin-left: 10px; }
.flex-gap-12 > * + * { margin-left: 12px; }

```

`packages\tgui\styles\reset.scss`

```scss
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

@use './base.scss';

html,
body {
  box-sizing: border-box;
  height: 100%;
  margin: 0;
  font-size: base.$font-size;
}

html {
  overflow: hidden;
  cursor: default; // Reset the cursor.
}

body {
  overflow: auto;
  font-family: 'SF Pro Display', 'Helvetica Neue', 'Helvetica', 'Arial',
    sans-serif;
}

*,
*:before,
*:after {
  box-sizing: inherit;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  display: block;
  margin: 0;
  padding: 6px 0;
  padding: 0.5rem 0;
}

h1 {
  font-size: 18px;
  font-size: 1.5rem;
}

h2 {
  font-size: 16px;
  font-size: 1.333rem;
}

h3 {
  font-size: 14px;
  font-size: 1.167rem;
}

h4 {
  font-size: 12px;
  font-size: 1rem;
}

td,
th {
  vertical-align: baseline;
  text-align: left;
}

```

`packages\tgui\styles\themes\neutral.scss`

```scss
@use "sass:color";

[class^="theme-neutral-"] {
  .Layout.Window {
    background-image: none;
  }

  .Input,
  .NumberInput {
    border: none;
  }

  .SettingsWindow {
    background-image: none !important;
  }

  .PreferencesCategory {
    cursor: pointer;
    background-color: #1c1c1c;

    &:hover,
    &:focus {
      background-color: #3a3a3a;
    }
  }

  .PreferenceOption {
    background-color: #1c1c1c;

    &:hover,
    &:focus {
      background-color: #3a3a3a;
    }

    &.Button--selected {
      background-color: #1b9638;
    }
  }

  .Button {
    cursor: pointer;
    background-color: #1c1c1c;

    &:focus,
    &:hover {
      background-color: #3a3a3a;
    }
  }

  .Tabs {
    cursor: pointer;
  }

  .Dropdown__control {
    background-color: #0a0a0a;
    cursor: pointer;

    &:hover,
    &:focus {
      background-color: #3a3a3a;
    }
  }

  .PreviewWindow {
    position: relative;
    border: 2px solid #1c1c1c;
    border-radius: 2px;

    &-Background {
      position: relative;
      width: 480px;
      height: 480px;
      background-image: url("../../assets/settings/preview.png");
    }

    &-Hud {
      position: absolute;
      top: 0;
      width: 480px;
      height: 480px;
    }

    &-Items {
      position: absolute;
      top: 0;
      width: 480px;
      height: 480px;
      background-image: url("../../assets/settings/items.png");
    }
  }

  .Section__title {
    border-bottom-color: #3b3b3b;
  }

  .Table tbody :first-child {
    margin: 4px;
  }

  .Table tbody tr:nth-child(even) {
    background-color: color.adjust($color: black, $alpha: -0.9);
  }
}

```

`packages\tgui\styles\themes\primer.scss`

```scss
$border-radius: 0.4rem;
$border-thick: 0.1rem;
$background-size: 8rem;

.Layout,
.Layout * {
  @at-root .theme-primer-white & {
    scrollbar-base-color: #f6f8fa;
    scrollbar-face-color: #f6f8fa;
    scrollbar-3dlight-color: #f6f8fa;
    scrollbar-highlight-color: #f6f8fa;
    scrollbar-track-color: #d9dbdb;
    scrollbar-arrow-color: #f6f8fa;
    scrollbar-shadow-color: #d9dbdb;
  }

  @at-root .theme-primer-dark & {
    scrollbar-base-color: #2d333b;
    scrollbar-face-color: #2d333b;
    scrollbar-3dlight-color: #22272e;
    scrollbar-highlight-color: #22272e;
    scrollbar-track-color: #22272e;
    scrollbar-arrow-color: #2d333b;
    scrollbar-shadow-color: #2d333b;
  }
}

.Layout__content {
  @at-root .theme-primer-white & {
    background-color: #0366d6;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 100 100'%3E%3Cg fill-rule='evenodd'%3E%3Cg fill='%2379b8ff' fill-opacity='.7'%3E%3Cpath opacity='.5' d='M96 95h4v1h-4v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9zm-1 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9z'/%3E%3Cpath d='M6 5V0H5v5H0v1h5v94h1V6h94V5H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
    background-repeat: repeat;
    background-size: 8rem;
  }

  @at-root .theme-primer-dark & {
    background-color: #17283b;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 100 100'%3E%3Cg fill-rule='evenodd'%3E%3Cg fill='%2379b8ff' fill-opacity='.2'%3E%3Cpath opacity='.5' d='M96 95h4v1h-4v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9zm-1 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9z'/%3E%3Cpath d='M6 5V0H5v5H0v1h5v94h1V6h94V5H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
    background-repeat: repeat;
    background-size: $background-size;
  }
}

.Section {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    border-radius: $border-radius;
    font-size: 1.2rem;

    &__title {
      text-align: center;

      &Text {
        font-size: 1.2em;
      }
    }
  }

  @at-root .theme-primer-white & {
    background-color: #f6f8fa;
    color: #24292e;
    border: #d9dbdb solid $border-thick;

    &__rest {
      color: #586069;
    }

    &__title {
      border-bottom: #d9dbdb solid $border-thick;
      background-color: #ffffff;

      &Text {
        color: #24292e;
      }
    }
  }

  @at-root .theme-primer-dark & {
    background-color: #22272e;
    color: white;
    border: #373e47 solid $border-thick;

    &__rest {
      color: #768390;
    }

    &__title {
      border-bottom: #373e47 solid $border-thick;
      background-color: #2d333b;

      &Text {
        color: white;
      }
    }
  }
}

.TitleBar {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    border: none;
    box-shadow: none;
    user-select: none;
    -ms-user-select: none;
  }

  @at-root .theme-primer-white & {
    background-color: #ffffff;
    border-bottom: #d9dbdb solid $border-thick;

    &__title {
      color: black;
    }

    &__close {
      background-color: #ffffff;
      color: black;

      &:hover {
        background-color: red;
        color: white;
      }
    }
  }

  @at-root .theme-primer-dark & {
    background-color: #2d333b;
    border-bottom: #373e47 solid $border-thick;

    &__title {
      color: white;
    }

    &__close {
      background-color: #2d333b;
      color: white;

      &:hover {
        background-color: red;
        color: white;
      }
    }
  }
}

.Button {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    font-size: 0.9em;
    cursor: pointer;
    border-radius: $border-radius;
    transition: all 0.2s;

    &--disabled {
      cursor: default !important;
    }

    &--label {
      border: none !important;
      padding: 0.15rem 0.5rem;
      border-radius: 1rem;
      text-decoration: none;

      margin: {
        top: 0.15rem;
        right: 0.05rem;
        left: 0.15rem;
      }
    }

    &--link {
      font-weight: bold;
      background: none !important;
      cursor: pointer;
      border: none !important;
    }

    &--segmented {
      font-weight: bold;
      margin: 0;
      border-radius: 0;
      cursor: pointer;

      &:first-child {
        border-radius: $border-radius 0 0 $border-radius;
      }

      &:last-child {
        border-radius: 0 $border-radius $border-radius 0;
      }
    }
  }

  @at-root .theme-primer-white & {
    color: #24292e;
    background-color: #fafbfc;
    border: #d9dbdb solid $border-thick;

    &--color--bad {
      color: #cb2431;

      * {
        color: #cb2431 !important;
      }

      &:hover,
      &:focus,
      &--selected {
        color: white !important;
        background-color: #cb2431 !important;

        * {
          color: white !important;
        }
      }
    }

    &:focus,
    &:hover,
    &.Button--selected {
      background-color: #edeff2;
      border: #b3b6b9 solid $border-thick;
    }

    &.Button--disabled {
      color: #d9dbdb !important;
      background-color: #fafbfc !important;
      border: #d9dbdb solid $border-thick;

      * {
        color: #d9dbdb !important;
      }
    }

    &--label {
      background-color: #e7f3ff;
      color: #0366d6;

      &:focus,
      &:hover,
      &.Button--selected {
        background-color: #c4e2ff;
      }
    }

    &--link {
      color: #0366d6;

      &:focus,
      &:hover,
      &.Button--selected {
        color: #58a6ff;
        background-color: transparent !important;
      }

      &.Button--disabled {
        color: #586069;
        background-color: transparent !important;
      }
    }

    &--segmented {
      background-color: #fafbfc;
      color: #0366d6;

      border: {
        top: #d9dbdb solid $border-thick;
        bottom: #d9dbdb solid $border-thick;
        left: none;
        right: none;
      }

      &:focus,
      &:hover,
      &.Button--selected {
        color: white;
        background-color: #0366d6;

        border: {
          top: #3694ff solid $border-thick;
          right: none;
          left: none;
          bottom: #3694ff solid $border-thick;
        }

        * {
          color: white !important;
        }
      }

      &:first-child {
        border: {
          top: #d9dbdb solid $border-thick;
          left: #d9dbdb solid $border-thick;
          right: none;
          bottom: #d9dbdb solid $border-thick;
        }

        &:focus,
        &:hover,
        &.Button--selected {
          background-color: #0366d6;
          border-top: #3694ff solid $border-thick;
          border-left: #3694ff solid $border-thick;
          border-bottom: #3694ff solid $border-thick;
        }
      }

      &:last-child {
        border: {
          top: #d9dbdb solid $border-thick;
          left: none;
          right: #d9dbdb solid $border-thick;
          bottom: #d9dbdb solid $border-thick;
        }

        &:focus,
        &:hover,
        &.Button--selected {
          background-color: #0366d6;

          border: {
            top: #3694ff solid $border-thick;
            left: none;
            right: #3694ff solid $border-thick;
            bottom: #3694ff solid $border-thick;
          }
        }
      }

      &.Button--disabled {
        color: #959da5;
        background-color: #fafbfc !important;

        border: {
          top: #d9dbdb solid $border-thick;
          bottom: #d9dbdb solid $border-thick;
          left: none;
          right: none;
        }

        &:hover,
        &:focus {
          border: {
            top: #d9dbdb solid $border-thick;
            bottom: #d9dbdb solid $border-thick;
          }
        }

        &:first-child {
          border-left: #d9dbdb solid $border-thick;
        }

        &:last-child {
          border-right: #d9dbdb solid $border-thick;
        }
      }
    }
  }

  @at-root .theme-primer-dark & {
    color: #c9d1d9;
    background-color: #21262d;
    border: #444c56 solid $border-thick;

    &--color--bad {
      color: #d73a49;

      * {
        color: #d73a49 !important;
      }

      &:hover,
      &:focus,
      &--selected {
        color: white !important;
        background-color: #cb2431 !important;

        * {
          color: white !important;
        }
      }
    }

    &:focus,
    &:hover,
    &.Button--selected {
      background-color: #444c56;
      border: #768390 solid $border-thick;
    }

    &.Button--disabled {
      color: #666c72 !important;
      background-color: #21262d !important;
      border: #444c56 solid $border-thick;

      * {
        color: #666c72 !important;
      }
    }

    &--label {
      background-color: #263b58;
      color: #58a6ff;

      &:focus,
      &:hover,
      &.Button--selected {
        color: #58a6ff;
        background-color: #2d5996;
      }
    }

    &--link {
      color: #58a6ff;

      &:focus,
      &:hover,
      &.Button--selected {
        color: white;
        background-color: transparent !important;
      }

      &.Button--disabled {
        color: #586069 !important;
        background-color: transparent !important;
      }
    }

    &--segmented {
      background-color: #22272e;
      color: #58a6ff;

      border: {
        top: #444c56 solid $border-thick;
        bottom: #444c56 solid $border-thick;
        left: none;
        right: none;
      }

      &:focus,
      &:hover,
      &.Button--selected {
        color: white;
        background-color: #0366d6;

        border: {
          top: #3694ff solid $border-thick;
          right: none;
          left: none;
          bottom: #3694ff solid $border-thick;
        }

        * {
          color: white !important;
        }
      }

      &:first-child {
        border: {
          top: #444c56 solid $border-thick;
          left: #444c56 solid $border-thick;
          right: none;
          bottom: #444c56 solid $border-thick;
        }

        &:focus,
        &:hover,
        &.Button--selected {
          background-color: #0366d6;
          border-top: #3694ff solid $border-thick;
          border-left: #3694ff solid $border-thick;
          border-bottom: #3694ff solid $border-thick;
        }
      }

      &:last-child {
        border: {
          top: #444c56 solid $border-thick;
          left: none;
          right: #444c56 solid $border-thick;
          bottom: #444c56 solid $border-thick;
        }

        &:focus,
        &:hover,
        &.Button--selected {
          background-color: #0366d6;

          border: {
            top: #3694ff solid $border-thick;
            left: none;
            right: #3694ff solid $border-thick;
            bottom: #3694ff solid $border-thick;
          }
        }
      }

      &.Button--disabled {
        color: #5c6772;
        background-color: #293037 !important;

        border: {
          top: #444c56 solid $border-thick;
          bottom: #444c56 solid $border-thick;
          left: none;
          right: none;
        }

        &:hover,
        &:focus {
          border: {
            top: #444c56 solid $border-thick;
            bottom: #444c56 solid $border-thick;
          }
        }

        &:first-child {
          border-left: #444c56 solid $border-thick;
        }

        &:last-child {
          border-right: #444c56 solid $border-thick;
        }
      }
    }
  }
}

.Divider {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    &--hidden {
      border: none !important;
    }
  }

  @at-root .theme-primer-white & {
    border-top: #d9dbdb solid $border-thick;
  }

  @at-root .theme-primer-dark & {
    border-top: #373e47 solid $border-thick;
  }

  &--vertical {
    @at-root .theme-primer-white & {
      border-left: #d9dbdb solid $border-thick;
    }

    @at-root .theme-primer-dark & {
      border-left: #373e47 solid $border-thick;
    }
  }
}

.ProgressBar {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    border-radius: $border-radius;

    &__fill {
      border-radius: $border-radius;
    }
  }

  @at-root .theme-primer-white & {
    border: #d9dbdb solid $border-thick;

    &__fill {
      background-color: #28a745;
    }
  }

  @at-root .theme-primer-dark & {
    border: #373e47 solid $border-thick;

    &__fill {
      background-color: #238636;
    }
  }
}

.Input {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    border-radius: $border-radius;
  }

  @at-root .theme-primer-white & {
    color: #24292e;
    background-color: #ffffff;
    border: #e1e4e8 solid $border-thick;

    &__input {
      &:-ms-input-placeholder {
        color: #959da5;
      }
    }
  }

  @at-root .theme-primer-dark & {
    color: white;
    background-color: #22272e;
    border: #373e47 solid $border-thick;

    &__input {
      &:-ms-input-placeholder {
        color: #768390;
      }
    }
  }
}

.Section__buttons {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    margin-top: -0.15em;
  }
}

.Layout__content .Icon {
  @at-root .theme-primer-white & {
    color: #959da5;
  }

  @at-root .theme-primer-dark & {
    color: #6e7681;
  }
}

.Tabs {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    border-radius: $border-radius;
  }

  @at-root .theme-primer-white & {
    background-color: #fafbfc;

    & * {
      color: #24292e;
    }
  }

  @at-root .theme-primer-dark & {
    background-color: #22272e;

    & * {
      color: #c9d1d9;
    }
  }

  .Tab {
    @at-root .theme-primer-white &,
      .theme-primer-dark & {
      cursor: pointer;
      padding: {
        left: 0.4rem;
        right: 0.4rem;
      }
      background-color: transparent !important;
    }

    @at-root .theme-primer-white & {
      border-bottom: #fafbfc solid 0.2rem;
    }

    @at-root .theme-primer-dark & {
      border-bottom: #22272e solid 0.2rem;
    }

    &:hover {
      @at-root .theme-primer-white & {
        border-bottom: #d1d5da solid 0.2rem;
      }

      @at-root .theme-primer-dark & {
        border-bottom: #636e7b solid 0.2rem;
      }
    }

    &:focus,
    &--selected {
      @at-root .theme-primer-white & {
        border-bottom: #f9826c solid 0.2rem !important;
      }

      @at-root .theme-primer-dark & {
        border-bottom: #f9826c solid 0.2rem !important;
      }
    }
  }
}

.candystripe {
  @at-root .theme-primer-white & {
    background-color: #f6f8fa;

    &:nth-child(odd) {
      background-color: #eeeeee;
    }
  }

  @at-root .theme-primer-dark & {
    background-color: #22272e;

    &:nth-child(odd) {
      background-color: #2d333b;
    }
  }
}

.Materials .game-icon {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    width: 4em;
    height: 4em;
    vertical-align: -2rem;
  }
}

.Materials--small .game-icon {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    width: 2em;
    height: 2em;
    vertical-align: -1rem;
  }
}

.Designs .game-icon {
  @at-root .theme-primer-white &,
    .theme-primer-dark & {
    width: 3em;
    height: 3em;
    vertical-align: -1.5rem;
  }
}

.Table {
  &.Table--bordered {
    @at-root .theme-primer-white & {
      border: #e1e4e8 solid $border-thick;
    }

    @at-root .theme-primer-dark & {
      border: #373e47 solid $border-thick;
    }
  }
}

```

