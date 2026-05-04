import { useBackend } from "../backend";
import {
  Button,
  Stack,
  Section,
  LabeledList,
  Box,
  Icon,
  Slider,
} from "../components";
import { Window } from "../layouts";

interface OrbitalShakerData {
  is_running: number;
  target_stirring: number;
}

export const OrbitalShaker = (props: any, context: any) => {
  const { act, data } = useBackend<OrbitalShakerData>(context);

  return (
    <Window width={350} height={250} title="Orbital Shaker">
      <Window.Content scrollable>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Box
                inline
                px={1}
                py={0.25}
                borderRadius="4px"
                fontWeight="bold"
                backgroundColor={
                  data.is_running
                    ? "rgba(26,138,92,0.15)"
                    : "rgba(192,57,43,0.15)"
                }
                color={data.is_running ? "#1a8a5c" : "#c0392b"}
              >
                <Icon
                  name={data.is_running ? "sync-alt" : "power-off"}
                  spin={data.is_running}
                  mr={0.5}
                />
                {data.is_running ? "Running" : "Stopped"}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Intensity">
              <Box bold>{Math.round(data.target_stirring * 100)}%</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Controls">
          <Stack vertical>
            <Stack.Item>
              <Button
                fluid
                icon={data.is_running ? "stop" : "play"}
                content={data.is_running ? "Stop Shaker" : "Start Shaker"}
                color={data.is_running ? "bad" : "good"}
                onClick={() => act("toggle_power")}
              />
            </Stack.Item>
            <Stack.Item>
              <Box mb={0.5} color="label">
                Stirring Intensity
              </Box>
              <Slider
                value={data.target_stirring}
                minValue={0}
                maxValue={1}
                step={0.01}
                stepPixelSize={2}
                onChange={(e, value) => act("set_stirring", { value })}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
