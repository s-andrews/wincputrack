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
    ungroup() %>%
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
  filter(max(CPU) > 100) %>%
  ungroup() %>%
  ggplot(aes(x=date,y=CPU, colour=Program)) +
  geom_line(size=2) -> plot

ggsave(svg_file, plot=plot, device = "svg", width = 11, height = 4, units = "in")

