---
title: "AVR-Based Automatic Plant Watering System"
image_link: "assets/images/avr.png"
image_alt: "A Printed-Circuit-Board"
teaser: "
    An AVR-MCU-based automatic plant watering system. End-to-end developed on a custom PCB in Altium designer, bare-metal C code without the use of HALs and a custom case designed in FreeCAD    
    "
links:
    - text: "Github Repo"
      url: "https://github.com/Tabzeen/avr_watering_system" 
      icon: "fa-brands fa-github"
type: 1
priority: 2
has_blog: false 
---

# {{page.title}}

## Abstract

In the context of a larger university project, I have built an fully automatic plant watering system. The system uses a capacitive soil sensor to detect moisture and triggers a motorized pump whenever the levels drop outside of a user defined range. As an interface to the user, the system integrates a simple 2 row LCD display to show status and settings. Configuration of water thresholds can be performed via two buttons on the top of the unit. As protection for overwatering, the system features a failure protection, which disables the pump when the sensor values do not change during watering.

I built an automatic plant watering system that takes the guesswork out of plant care by relying on real-time capacitive sensor values. It actively detects soil moisture and triggers a motorized pump whenever the levels drop outside a range I configured. To make it user-friendly, I integrated an LCD display to show the current status and added two buttons on top of the unit to easily adjust the watering thresholds. The system also features pump and sensor failure protection, safely shutting off automatically if the sensor values do not change during watering.

## Initial Idea
As a starting point I defined the basic feature set which I wanted the board to have, and which type of features seemed realistic in the project scope and semester timeframe. In total the set of base features consisted of the following:
- Detect the soil moisture and water the plant if it is outside a user-set range.
- Provide water to the plant by a motorized pump.
- Display Status to the user via an LCD Display.
- Allow the user th adjust settings using two buttons on top of the unit.

Furthermore, I defined additional optional features:
- One preset slot to store and load user set settings
    - Persistent after shutdown
• Pump / Sensor failure protection
• Automatic shutoff when Sensor values don’t change.

The original concept was straightforward: pull water from a separate container into the flowerpot whenever a soil sensor inside the pot detected dry conditions. I wanted a simple LCD interface that could display both the current and target humidity levels. To control it, the plan was to use two buttons or a dial to manually set the target moisture boundaries, seamlessly starting and stopping the pump based on those parameters. 

## Prototyping
I began prototyping using an Arduino Nano equipped with an ATMega328PB, choosing to simulate the conditions of a raw chip by writing bare-metal code rather than relying on the bloated Arduino bootloader and standard libraries. I used a standard Arduino UNO as an ISP programmer and wired up a second Nano specifically for UART debugging. Because the motor demanded too heavy of a load for the early testing phase, I simulated the pump's activation using an LED.

## Used Components
The final hardware stack relies on several key components:
* My custom-designed mainboard.
* A custom interface board.
* An Adafruit I2C capacitive moisture sensor featuring an on-board Seesaw controller.
* A 16x2 character I2C LCD panel driven by a built-in AiP31068L controller and PCA9633 driver.
* A 5V pneumatic pump to deliver the water.

## Board design and architecture
I designed a custom 2-layer FR-4 board measuring 66mm by 78mm. The top layer is dedicated to the motor and controller sections, while the bottom layer acts primarily as a ground plane. Power is delivered via a DC barrel jack rated for a maximum of 5V at 1.7A. The board includes essential I/O pin headers, two I2C connectors, an ISP header, a UART interface, and two onboard LEDs.

The brain of the operation is an ATmega328P microcontroller, featuring an 8-bit RISC CPU running at 16MHz via an external crystal. It houses 32KB of program flash storage and 1KB of rewritable EEPROM. For the interface and motor components, I manually sawed and drilled a perfboard to fit the required dimensions. Over the course of development, the board evolved through several revisions, ultimately gaining critical decoupling circuitry and expanded polygon pours for better stability.

## Software architecture and interface
I wrote the firmware entirely in bare-metal C, relying heavily on AVR macros (`avr/io.h`) and standard string libraries to handle formatting. The compiled binary is incredibly lightweight, coming in at just around 6KB. Since I avoided standard Arduino libraries, I wrote my own custom drivers to handle the TWI, UART, and device interaction.

The interface is driven by a simple state machine controlled by SET and MODE buttons. Pressing MODE cycles through three distinct states:
* **Monitoring Mode:** Displays the current moisture reading and allows the motor to be disabled with the SET button.
* **Set Mode:** Allows me to configure the minimum and maximum moisture percentage bounds for watering.
* **Store Mode:** Saves the current settings into a preset slot within the EEPROM, which is automatically loaded on device startup. 

The min and max thresholds are stored directly as 8-bit integers in the first two addresses of the EEPROM (0x00 and 0x01). In the background, a core loop periodically pulls raw data from the sensor, converts it to a percentage, and compares it to the saved EEPROM bounds to control the motor state.

## Case Design 
I drafted the enclosure in FreeCAD as a two-part shell to house all the internal components cleanly. I 3D printed it using green and white PLA filament, opting for thick walls and 100% infill to ensure a highly sturdy structure. The final dimensions are 138 x 85 x 80 mm.

To securely close the unit, I fitted screw threads into the plastic casing, allowing the entire assembly to be bolted together flush with M3 screws. The front and sides feature precise cutouts for the LCD interface and power delivery.

## Case Assembly and board programming
While the mainboard was mostly assembled at the factory, I had to manually remove a few resistors and solder on the through-hole components and diodes once the PCB arrived. The internal connections between the mainboard, the perfboard interface, and the peripherals were all routed manually using jumper wires. Programming the ATmega328P was done in-system using AVRDude through my Arduino as ISP setup. 

## Roadblocks and summary
Building this entirely from scratch wasn't without its headaches. Jumper wires and breadboards provided highly unreliable connections during the prototyping phase. I actually managed to brick one of my early boards by accidentally configuring the fuse settings to expect an external clock instead of a crystal. 

Power delivery was another major hurdle. On the early prototype, the motor caused massive brownouts that crashed the microcontroller. I solved this in the final PCB revision by adding significantly more decoupling circuitry. Additionally, the Adafruit capacitive sensor I bought didn't have a standard datasheet; because it relied on their proprietary Seesaw controller intended for Arduino libraries, I had to dig through Adafruit's source code just to extract the correct Read/Write I2C addresses.

Despite the hardware quirks, I successfully built a standalone, reliable plant watering system with custom thresholds and EEPROM memory management. Future iterations might include polarity protection, JST connectors instead of jumper wires, battery power integration, and an RTC for time-based watering constraints.