import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Stack,
  Section,
  Box,
  Icon,
  Tabs,
  Table,
  NoticeBox,
} from "../components";
import { Window } from "../layouts";

interface SupplyTerminalData {
  is_admin: boolean;
  credits: number;
  currency: string;
  cart_total: number;
  cart_count: number;
  categories: string[];
  selected_category: string;
  possible_purchases: PurchaseItem[];
  cart: CartItem[];
  history: HistoryEntry[];
  history_page: number;
  history_total_pages: number;
  history_count: number;
}

interface PurchaseItem {
  name: string;
  vendor: string;
  cost: number;
  ref: string;
  in_cart: number;
}

interface CartItem {
  id: number;
  object: string;
  vendor: string;
  orderer: string;
  cost: number;
}

interface HistoryEntry {
  time: string;
  items: string;
  diff: number;
  color: string;
  type: string;
}

const TAB_CATALOG = 1;
const TAB_CART = 2;
const TAB_HISTORY = 3;

const CatalogTab = (props: any, context: any) => {
  const { act, data } = useBackend<SupplyTerminalData>(context);
  const { categories, selected_category, possible_purchases, currency } = data;

  return (
    <>
      {/* Category selector */}
      <Section>
        <Stack wrap>
          {categories.map((cat) => (
            <Stack.Item key={cat}>
              <Button
                content={cat}
                selected={cat === selected_category}
                onClick={() => act("select_category", { category: cat })}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Section>

      {/* Items in selected category */}
      {selected_category && possible_purchases.length > 0 && (
        <Section title={selected_category}>
          <Table>
            <Table.Row header>
              <Table.Cell width="35%">Item</Table.Cell>
              <Table.Cell width="25%">Vendor</Table.Cell>
              <Table.Cell width="15%">Cost</Table.Cell>
              <Table.Cell width="25%">Order</Table.Cell>
            </Table.Row>
            {possible_purchases.map((item) => (
              <Table.Row key={item.ref}>
                <Table.Cell>{item.name}</Table.Cell>
                <Table.Cell color="label">{item.vendor}</Table.Cell>
                <Table.Cell>
                  {item.cost.toLocaleString()} {currency}
                </Table.Cell>
                <Table.Cell nowrap>
                  <Button
                    icon="plus"
                    content="Add to Cart"
                    color="good"
                    onClick={() => act("add_to_cart", { ref: item.ref })}
                  />
                  {item.in_cart > 0 && (
                    <Box
                      inline
                      backgroundColor="good"
                      color="white"
                      px="6px"
                      py="2px"
                      ml="5px"
                      verticalAlign="middle"
                      lineHeight="1"
                    >
                      {item.in_cart}
                    </Box>
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      )}

      {/* Empty state when category is selected but has no items */}
      {selected_category && possible_purchases.length === 0 && (
        <Section title={selected_category}>
          <Box color="label" textAlign="center" py={2}>
            No items available in this category.
          </Box>
        </Section>
      )}

      {/* Prompt to select a category */}
      {!selected_category && (
        <Section>
          <Stack align="center" justify="center" height="6rem">
            <Stack.Item>
              <Icon name="arrow-up" color="label" mr={1} />
            </Stack.Item>
            <Stack.Item>
              <Box color="label">
                Select a category above to browse available items.
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      )}
    </>
  );
};

const CartTab = (props: any, context: any) => {
  const { act, data } = useBackend<SupplyTerminalData>(context);
  const { cart, cart_total, cart_count, credits, currency, is_admin } = data;
  const canAfford = credits >= cart_total;

  if (cart_count === 0) {
    return (
      <Section>
        <Box textAlign="center">
          <h3>Shopping Cart</h3>
        </Box>
        <NoticeBox info textAlign="center">
          Your cart is empty.
        </NoticeBox>
      </Section>
    );
  }

  return (
    <Section>
      <Box textAlign="center">
        <h3>Shopping Cart</h3>
      </Box>
      <Table>
        <Table.Row header>
          <Table.Cell width="35%">Item</Table.Cell>
          <Table.Cell width="25%">Vendor</Table.Cell>
          <Table.Cell width="10%">Cost</Table.Cell>
          <Table.Cell width="15%">Options</Table.Cell>
        </Table.Row>
        {cart.map((item) => (
          <Table.Row key={item.id}>
            <Table.Cell>{item.object}</Table.Cell>
            <Table.Cell color="label">{item.vendor}</Table.Cell>
            <Table.Cell>
              {item.cost.toLocaleString()} {currency}
            </Table.Cell>
            <Table.Cell>
              <Button
                icon="times"
                content="Remove"
                color="bad"
                onClick={() => act("remove_from_cart", { id: item.id })}
              />
            </Table.Cell>
          </Table.Row>
        ))}
        <Table.Row>
          <Table.Cell colspan={3} textAlign="right" pt="10px">
            <b>TOTAL:</b>
          </Table.Cell>
          <Table.Cell colspan={2} pt="10px">
            <b>
              {cart_total.toLocaleString()} {currency}
            </b>
          </Table.Cell>
        </Table.Row>
      </Table>

      {/* Checkout area */}
      <Box mt={2} textAlign="center">
        {is_admin ? (
          <>
            <Button.Confirm
              icon="check"
              content="Checkout & Order"
              color="good"
              confirmContent="Confirm?"
              confirmColor="bad"
              disabled={!canAfford}
              onClick={() => act("checkout")}
            />
            {!canAfford && (
              <NoticeBox warning mt={1}>
                Insufficient funds for this order.
              </NoticeBox>
            )}
          </>
        ) : (
          <NoticeBox warning>
            Only personnel with access to the funds can finalize orders.
          </NoticeBox>
        )}
      </Box>
    </Section>
  );
};

const HistoryTab = (props: any, context: any) => {
  const { act, data } = useBackend<SupplyTerminalData>(context);
  const {
    history,
    history_page,
    history_total_pages,
    history_count,
    currency,
  } = data;

  return (
    <Section
      title={
        <Box inline>
          <h3 style={{ display: "inline", margin: 0 }}>Operation History</h3>
        </Box>
      }
      buttons={
        history_count > 0 && (
          <Stack align="center">
            <Stack.Item>
              <Button
                icon="angle-double-left"
                disabled={history_page <= 1}
                tooltip="First page"
                onClick={() => act("set_history_page", { page: 1 })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-left"
                disabled={history_page <= 1}
                tooltip="Previous page"
                onClick={() =>
                  act("set_history_page", { page: history_page - 1 })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Box bold textAlign="center" px={1} minWidth="5rem">
                {history_page} / {history_total_pages}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={history_page >= history_total_pages}
                tooltip="Next page"
                onClick={() =>
                  act("set_history_page", { page: history_page + 1 })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="angle-double-right"
                disabled={history_page >= history_total_pages}
                tooltip="Last page"
                onClick={() =>
                  act("set_history_page", { page: history_total_pages })
                }
              />
            </Stack.Item>
          </Stack>
        )
      }
    >
      {history_count === 0 ? (
        <NoticeBox info textAlign="center">
          No operations recorded.
        </NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell width="20%">Time</Table.Cell>
            <Table.Cell width="20%">Items</Table.Cell>
            <Table.Cell width="60%" textAlign="right">
              Diff
            </Table.Cell>
          </Table.Row>
          {history.map((entry, idx) => (
            <Table.Row key={idx}>
              <Table.Cell>{entry.time}</Table.Cell>
              <Table.Cell>{entry.items}</Table.Cell>
              <Table.Cell textAlign="right" color={entry.color}>
                {entry.type === "sell" ? "↑" : "↓"} {entry.diff.toLocaleString()} {currency}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

export const SupplyTerminal = (props: any, context: any) => {
  const { act, data } = useBackend<SupplyTerminalData>(context);
  const [tab, setTab] = useLocalState(context, "supplyTab", TAB_CATALOG);

  const { credits, currency, is_admin } = data;

  return (
    <Window width={1050} height={800} title="Supply Terminal">
      <Window.Content scrollable>
        {is_admin ? (
          <NoticeBox info>
            You are authenticated. You may access all functions of this program.
          </NoticeBox>
        ) : (
          <NoticeBox>
            You are unauthenticated. Some functions may be unavailable.
          </NoticeBox>
        )}

        {/* Tab navigation */}
        <Section>
          <Tabs>
            <Tabs.Tab
              icon="book"
              selected={tab === TAB_CATALOG}
              onClick={() => setTab(TAB_CATALOG)}
            >
              Browse Goods
            </Tabs.Tab>
            <Tabs.Tab
              icon="calculator"
              selected={tab === TAB_CART}
              onClick={() => setTab(TAB_CART)}
            >
              Shopping Cart
            </Tabs.Tab>
            <Tabs.Tab
              icon="history"
              selected={tab === TAB_HISTORY}
              onClick={() => setTab(TAB_HISTORY)}
            >
              History
            </Tabs.Tab>
          </Tabs>
        </Section>

        {/* Balance bar */}
        <Section>
          <Stack align="center" justify="space-between">
            <Stack.Item>
              <Box inline color="label" mr={1}>
                Current balance:
              </Box>
              <Box inline bold>
                {credits.toLocaleString()} {currency}
              </Box>
            </Stack.Item>
            {is_admin && (
              <Stack.Item>
                <Button.Confirm
                  icon="arrow-down"
                  content="Sell Goods in Bay"
                  confirmContent="Confirm sale?"
                  confirmColor="good"
                  onClick={() => act("sell")}
                />
              </Stack.Item>
            )}
          </Stack>
        </Section>

        {/* Tab content */}
        {tab === TAB_CATALOG && <CatalogTab />}
        {tab === TAB_CART && <CartTab />}
        {tab === TAB_HISTORY && <HistoryTab />}
      </Window.Content>
    </Window>
  );
};
