library(fs)
library(tidyverse)
library(lubridate)

paste(fs::path_home(),"wincputrack.log", sep="/") -> log_file
paste(fs::path_home(),"wincputrack.svg", sep="/") -> svg_file

read_delim(log_file, col_names=c("Epoch","Program","CPU")) -> data

data %>%
    mutate(
        Program = str_replace(Program,"#.*","")
    ) %>%
    group_by(Epoch,Program) %>%
    summarise(CPU=sum(CPU)) %>%
    ungroup() -> data

# Because we don't record processes with zero CPU they may be missing
# from some epochs.  We need to add in a zero to any observed epoch where
# a given process is not seen.

data %>%
  pivot_wider(
    names_from=Program,
    values_from=CPU
  ) %>%
  pivot_longer(
    cols=-Epoch,
    names_to="Program",
    values_to="CPU"
  ) %>%
  mutate(
    CPU=replace_na(CPU,0)
  ) -> data


data %>%
    mutate(
        date=as_datetime(Epoch)
    ) -> data

# Take out any stupid spikes which can't be right
data %>%
  mutate(
    CPU=replace(CPU,CPU>800,800)
  ) -> data

data %>%
  filter(Program != "Idle") -> data


data %>%
  group_by(Program) %>%
  filter(max(CPU) > 90) %>%
  ungroup() %>%
  ggplot(aes(x=date,y=CPU, colour=Program)) +
  geom_line(size=1) +
  geom_point(size=2) -> plot

ggsave(svg_file, plot=plot, device = "svg", width = 11, height = 4, units = "in")

