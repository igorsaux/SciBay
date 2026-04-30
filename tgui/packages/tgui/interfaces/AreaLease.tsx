import { useBackend } from "../backend";
import {
  Button,
  Stack,
  Section,
  LabeledList,
  NoticeBox,
  Box,
  Icon,
} from "../components";
import { Window } from "../layouts";

interface AreaLeaseData {
  credits: number;
  valid_area: boolean;
  is_for_sale: boolean;
  area_name: string;
  area_price: number;
  can_afford: boolean;
}

const ZoneStatus = (props: { forSale: boolean }) => {
  const { forSale } = props;
  return (
    <Box
      inline
      px={1}
      py={0.25}
      borderRadius="4px"
      fontWeight="bold"
      backgroundColor={
        forSale ? "rgba(26,138,92,0.15)" : "rgba(192,57,43,0.15)"
      }
      color={forSale ? "#1a8a5c" : "#c0392b"}
    >
      <Icon name={forSale ? "check-circle" : "times-circle"} mr={0.5} />
      {forSale ? "Available" : "Unavailable"}
    </Box>
  );
};

export const AreaLease = (props: any, context: any) => {
  const { act, data } = useBackend<AreaLeaseData>(context);

  if (!data.valid_area) {
    return (
      <Window width={440} height={300} title="Lease Terminal">
        <Window.Content fitted>
          <Section fill>
            <Stack align="center" justify="center" height="100%">
              <Stack.Item>
                <Icon name="exclamation-triangle" size={3} color="bad" />
              </Stack.Item>
              <Stack.Item grow baseline>
                <Box bold color="bad" mb={0.5}>
                  Invalid Zone
                </Box>
                <Box color="label" lineHeight={1.5}>
                  Terminal is not located in a leasable zone.
                  <br />
                  Please contact local services for relocation.
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  if (!data.is_for_sale) {
    return (
      <Window width={440} height={300} title="Lease Terminal">
        <Window.Content fitted>
          <Section fill>
            <Stack align="center" justify="center" height="100%">
              <Stack.Item>
                <Icon name="ban" size={3} color="average" />
              </Stack.Item>
              <Stack.Item grow baseline>
                <Box bold color="average" mb={0.5}>
                  Not Available
                </Box>
                <Box color="label" lineHeight={1.5}>
                  The area <b>{data.area_name}</b> is currently not available
                  for lease.
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const isFree = data.area_price === 0;
  const balanceAfter = data.credits - data.area_price;

  return (
    <Window width={440} height={400} title="Lease Terminal">
      <Window.Content scrollable>
        <Section title="Property Lease Agreement">
          <LabeledList>
            <LabeledList.Item label="Property">
              <Stack align="center">
                <Stack.Item>
                  <Icon name="map-marker-alt" color="good" />
                </Stack.Item>
                <Stack.Item grow>
                  <Box bold>{data.area_name}</Box>
                </Stack.Item>
                <Stack.Item>
                  <ZoneStatus forSale />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Lease Price">
              {isFree ? (
                <Box bold color="good">
                  <Icon name="gift" mr={0.5} />
                  FREE
                </Box>
              ) : (
                <Stack align="baseline">
                  <Stack.Item>
                    <Box bold>{data.area_price}</Box>
                  </Stack.Item>
                  <Stack.Item color="label">₠</Stack.Item>
                </Stack>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Financial Summary">
          <LabeledList>
            <LabeledList.Item label="Your Balance">
              <Box bold>{data.credits} ₠</Box>
            </LabeledList.Item>
            {!isFree && (
              <LabeledList.Item label="Balance After Lease">
                <Box bold color={balanceAfter >= 0 ? "good" : "bad"}>
                  {balanceAfter} ₠
                </Box>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        <Section title="Confirmation">
          {data.can_afford ? (
            <Stack vertical>
              <NoticeBox info>
                <Stack align="center">
                  <Icon name="info-circle" />
                  <Stack.Item grow>
                    By signing you accept all terms and conditions of the lease
                    for <b>{data.area_name}</b>.
                  </Stack.Item>
                </Stack>
              </NoticeBox>
              <Button
                fluid
                icon="pencil-alt"
                content="Sign Lease Agreement"
                color="good"
                onClick={() => act("purchase")}
              />
            </Stack>
          ) : (
            <NoticeBox>
              <Stack align="center">
                <Icon name="exclamation-circle" />
                <Stack.Item grow>
                  Insufficient funds — you need at least{" "}
                  <b>{data.area_price} ₠</b> to lease this property.
                </Stack.Item>
              </Stack>
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
