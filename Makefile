INCLUDES=\
	-DSTM32F746xx \
	-I./ \
	-Ivendor/stm32cubef7/Drivers/CMSIS/Include/ \
	-Ivendor/stm32cubef7/Drivers/CMSIS/Device/ST/STM32F7xx/Include/ \
	-Ivendor/stm32cubef7/Drivers/STM32F7xx_HAL_Driver/Inc/

CFLAGS= \
	-g \
	-mthumb \
	-mcpu=cortex-m4 \
	-mfpu=fpv4-sp-d16 \
	-mfloat-abi=hard \
	-ffunction-sections \
	-fdata-sections

%.o: %.c
	arm-none-eabi-gcc $(INCLUDES) $(CFLAGS) -c -MP -MD -o $@ $<
%.o: %.s
	arm-none-eabi-gcc $(INCLUDES) $(CFLAGS) -c -MP -MD -o $@ $<

HAL_SOURCES=$(wildcard vendor/stm32cubef7/Drivers/STM32F7xx_HAL_Driver/Src/*.c)
HAL_OBJECTS=$(patsubst %.S,%.o,$(patsubst %.c,%.o,$(HAL_SOURCES)))
HAL_DEPS=$(patsubst %.o,%.d,$(HAL_OBJECTS))

BIN_SOURCES=$(wildcard *.c) $(wildcard *.s)
BIN_OBJECTS=$(patsubst %.s,%.o,$(patsubst %.c,%.o,$(BIN_SOURCES)))
BIN_DEPS=$(patsubst %.o,%.d,$(BIN_OBJECTS))

all: stm32f7.elf
clean:
	rm libhal.a stm32f7.elf $(BIN_OBJECTS) $(HAL_OBJECTS) $(BIN_DEPS) $(HAL_DEPS)
.PHONY: all clean

libhal.a: $(HAL_OBJECTS)
	arm-none-eabi-ar rcu $@ $(HAL_OBJECTS)

stm32f7.elf: $(BIN_OBJECTS) libhal.a STM32F746NGHx_FLASH.ld
	arm-none-eabi-gcc $(CFLAGS) -Wl,-TSTM32F746NGHx_FLASH.ld -Wl,--gc-sections -o $@ $(BIN_OBJECTS) libhal.a


-include $(HAL_DEPS) $(BIN_DEPS)