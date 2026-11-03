---
title: "AVR-Based Automatic Plant Watering System"
blog_title: "Writeup: Development of an Automatic Plant Watering System"
image_link: "assets/images/avr.png"
image_alt: "A Printed-Circuit-Board"
teaser: "
    An AVR-MCU-based automatic plant watering system. End-to-end developed on a custom PCB in Altium Designer, bare-metal C code without the use of HALs and a custom case designed in FreeCAD    
    "
links:
    - text: "Github Repo"
      url: "https://github.com/Tabzeen/avr_watering_system" 
      icon: "fa-brands fa-github"
type: 1
priority: 2
has_blog: false
---

# {{page.blog_title}}
*Note: This writeup has been adapted from my presentation slides initially made in September 2025*
## Abstract

In the context of a larger university project, I have built an fully automatic plant watering system. The system uses a capacitive soil sensor to detect moisture and triggers a motorized pump whenever the levels drop outside of a user defined range. As an interface to the user, the system integrates a simple 2 row LCD display to show status and settings. Configuration of water thresholds can be performed via two buttons on the top of the unit. As protection for overwatering, the system features a failure protection, which disables the pump when the sensor values do not change during watering.

## Initial Idea
As a starting point I defined the basic feature set which I wanted the board to have, and which type of features seemed realistic in the project scope and semester timeframe. In total the set of base features consisted of the following:

- Detect the soil moisture and water the plant if it is outside a user-set range.
- Provide water to the plant by a motorized pump.
- Display Status to the user via an LCD Display.
- Allow the user th adjust settings using two buttons on top of the unit.

Furthermore, I defined additional optional features:
- One preset slot to store and load user settings, remaining persistent after shutdown.
- Pump and sensor failure protection with automatic shutoff when sensor values don’t change.

## Used Components

The final hardware stack uses the following components:
- A custom-designed mainboard.
- A custom interface board.
- An Adafruit I2C capacitive moisture sensor with an onboard Seesaw controller.
- A 16x2 character I2C LCD panel using an AiP31068L controller and PCA9633 driver.
- A 5V pneumatic pump to deliver the water.

## Prototyping

Before designing the circuit, I began prototyping using an Arduino Nano equipped with an ATmega328PB. In doing so, I intentionally avoided the standard Arduino libraries and bootloader to simulate the conditions of bare-metal development and provide more of a challenge. Flashing the Arduino was therefore done directly via the ISP pins of the AVR IC. As the flashing device, I used an Arduino UNO running custom firmware, which allowed me to flash the chip using AVRDude.

Components like the LCD and the soil sensor connected easily to the Nano prototype board. The pump, however, proved to be more of a problem. Its inrush current caused the AVR to brown out during startup, so for software development purposes, I replaced it with a simple indicator LED.

## Software architecture and interface

With the prototyping hardware assembled and the software stack established, I started developing the firmware.

As mentioned previously, I wrote the firmware entirely in bare-metal C, using AVR macros (`avr/io.h`) and standard C string libraries to handle formatting. As a result, the compiled binary is very lightweight at just around 6KB. Since I avoided the standard Arduino libraries, I wrote my own custom drivers for TWI and UART, and built the drivers for both the LCD and the Seesaw sensor on top of them.

For the LCD display, this was fairly straightforward, as its I2C interface is documented in an official TRM. The Seesaw sensor, however, is mainly intended for the Arduino ecosystem and only provided a library that relied on the standard Arduino libraries. Furthermore, the library was generalized to Seesaw's entire product catalog, which was insufficient for my minimal implementation.

Instead, I manually reconstructed the I2C interface from the library's source code and determined its Slave ID by writing test code on the Arduino to ping every address within a range. Using this information, I was able to recreate all the calls I needed for the Seesaw sensor while omitting features I didn't require, such as the temperature sensor.

For the interface, I was inspired by classic Casio watches, using only two buttons to cycle through menus and adjust configurations. It is driven by a simple state machine controlled by the SET and MODE buttons. Pressing MODE cycles through three states:
- **Monitoring Mode:** Displays the current moisture reading and allows the motor to be disabled with the SET button.
- **Set Mode:** Configures the minimum and maximum moisture percentage bounds for watering.
- **Store Mode:** Saves the current settings into a preset slot in the EEPROM, which is automatically loaded on startup.

The min and max thresholds are stored directly as 8-bit integers in the first two addresses of the EEPROM (`0x00` and `0x01`). In the background, the main loop periodically pulls raw data from the sensor, converts it to a percentage, and compares it against the saved EEPROM bounds to control the motor.

## Board design and architecture

Once the software and hardware worked on the prototype, I started working on the PCB itself. This project was my first real experience with Altium Designer and PCB design in general. As a result, the board went through several major iterations as I received feedback from my supervisor and gained more experience.

The first revision of the board established the general layout for the SMD components and jumper pins for external parts, using standard traces on the bottom layer for ground. In the second revision, I replaced those ground traces with a full polygon pour for the ground plane.

The third version was a larger redesign that addressed the decoupling needed for the AVR to run in parallel with the motor pump, adding the necessary capacitors and inductors to keep the IC stable while the motor runs. Final adjustments before sending the design out for manufacturing included additional debug LEDs, a polygon pour for the motor section, and M3 mounting holes at the outer edges of the board.

The final design is a 2-layer FR-4 board measuring 66mm by 78mm. The top layer is used for the motor and controller sections, while the bottom layer acts primarily as a ground plane. Power is supplied via a DC barrel jack rated for up to 5V at 1.7A. The board includes I/O pin headers, two I2C connectors, an ISP header, a UART interface, and two onboard LEDs. The main component is an ATmega328P microcontroller paired with an external crystal oscillator, providing 32KB of flash storage and 1KB of EEPROM.

For the interface and motor mounts, I manually sawed and drilled a perfboard to fit the required dimensions. While not particularly pretty, it served its purpose and was manageable under the given time constraints.

Flashing worked identically to the Arduino prototype via the ISP pins. However, during the flashing process, I managed to brick one board by setting the wrong clock fuse. Instead of setting the CKSEL fuse to an external crystal, I accidentally configured it to an external clock in AVRDude. Since the crystal received no power, the AVR ran at 0Hz and was essentially bricked. Other than that, the boards worked as expected, including the motor start and stop behavior.


## Case Design and Assembly

Finally, the system needed a case to house the boards. At the very beginning of the project, before any hardware work was done, I drafted a concept image of what the final system should look like.

However, once the internal components were assembled, the external design had to change quite a bit to fit the actual board dimensions. To get the enclosure right, I remeasured everything and drew a first layout sketch on paper.

Using my CAD experience from earlier 3D-printing projects, I modeled the enclosure in FreeCAD as a two-part shell. I 3D-printed it in green and white PLA with thick walls and 100% infill to make it sturdy. The final dimensions came out to 138 x 85 x 80 mm.

To close the unit, I added threaded inserts into the plastic casing so the assembly could be bolted together flush with M3 screws. The front and sides have cutouts for the LCD interface and power jack.

The cramped jumper cables made it a bit difficult to close the case properly, which took a few attempts. The jumper connections also proved to be somewhat unreliable at this stage, easily coming loose while putting the case together. However, once the lid was finally on, everything inside stayed in place, and the device powered on and worked as intended.

## Roadblocks and summary

Overall, I consider the project a success. However, there are a few things that could be improved and iterated on given more time. For one, the makeshift perfboards could be replaced with custom PCBs to properly mount the pump and the buttons. Since those boards wouldn't require any extra active components, ordering them would be relatively cheap. The second issue with the design was relying on jumper cables for the final wiring between components, which led to disconnects during both prototyping and final assembly. In future projects or revisions, I would probably use JST headers for permanent connections instead and only rely on jumper wires for flashing or debugging. All in all, it was a great introduction to PCB design and electrical engineering, and I learned a lot.