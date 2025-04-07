# How to Charge Batteries

> [!CAUTION]
> Do not process to charge the batteries if you are not completely sure of the procedure. Incorrect handling of these devices can cause serious damage to the equipment and the operator.

These instructions although they are inclined to how to charge our self-built drones battery packs, the recommendations and care mentioned are applicable to the commercial drones in our [catalog](/#drones) (like DJI drones). In case you want to charge any of the commercial platforms we have, please check our [catalog table](/#drones) to get the specific manual of that drone, there you will find the specific instructions how to charge the battery of that drone..

## Before to Start

Make sure to read the manual of the charger that are planning to use, see the table [Misc Utils](/#misc-utils) to find the links to the manuals.

## Materials

| ![charging items](/assets/charging-batteries/items.jpeg)                                                                                                                |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| The purpose of this image is to illustrate the example in this documentation. The components may vary in shape and size depending on which drone/charger you are using. |

In this example:
1. Charger: Graupner Ultramat 18
2. Battery: LiPo 6S1P 40/80C 5000 mAh
3. Battery checker: Smart Guard 2
4. Battery balance charging board: from 2S to 6S
5. Charging cable: XT90 to 4mm bannana plug

## Procedure

1. Before starting, always connect the balancer and the charging cable to the charger.

> [!WARNING]
> Never connect the charging cable to the battery before connecting the cable to the charger.

![charging balancer](/assets/charging-batteries/Ultramat-18-balancing.jpeg)

2. Visually inspect the battery to make sure there is no physical damage.

Does the battery appear to be in good condition with no physical damage (including terminals)? Yes: continue. No: Stop.

![charging balancer](/assets/charging-batteries/lipo-example-5000mAh.jpeg)

3. Using a battery tester/checker (in our example the Smart Guard 2) performs an electrical inspection of the current state of charge of the battery. This is important to ensure that the battery is not over charged or over discharged.

| ![charging pre-check](/assets/charging-batteries/battery-precheck.jpeg) |
|-------------------------------------------------------------------------|
| Use the balancer cables to check for the individual voltage cells       |

Are the voltages in the recommended range for the battery type? Yes: continue. No: stop, do not charge that battery.

4. Get the relavant battery charging parameters. These values depend on the battery you plan to charge take as an example the following battery:

| ![LiPo 5000mAh](/assets/charging-batteries/lipo-example-5000mAh.jpeg)                                                                                                                                                                                              |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| (1) 6S1P represents that this battery contains 6 LiPo cells in a single pack (all cells connected in series). (2) 40+/80C correspond to the **Discharging Rate** (letter C), refers to how quickly a battery can draw power. (3) 5000 mAh is the battery capacity. |

To proceed with the charging of a battery you need to know:
- Number of cells (integer unit): How many cell are in the pack. In this battery 6S.
- **CHARGING RATE** (integer unit)!! (no the Discharging Rate) CAREFUL !!: For most commercial batteries the charging rate is 1C. ⚠️ Never charge the battery with a charging rate higher than 1C.
- Battery capacit (Milliampere-hour): 5000 mAh 

5. Connect the balancer cable (1) and the main battery line (2) to the charger:

![Ultramat 18 setup](/assets/charging-batteries/Ultramat-18-setup.jpeg)

6. Enter the charging parameters:

Battery type: In most of our drones we use LiPo (lithium polymer) batteries. But always check the type of battery chemistry.

**Charging current**: This value can be very confusing as many battery chargers use the "C" symbol, which we had previously referred to as **Charge/Discharge Rate** in step four. But if you pay attention the charger uses the unit *ampere* "A" for this parameter actually referring to the **charging current** and not to the Charge/Discharge Rate. The charging current is the result of multiplying the Charging Rate with the battery capacity. For our example the charging rate most of the time is equal less than 1C times the battery capacity of 5000 mAh resulting in 5000 mA.

Battery capacity: as specified on the battery label.

resulting parameters for our example: 
- (1) Battery type: LiPo.
- (2) Charging current: 5000 mA or 5A.
- (3) Battery capacity: 5000 mAh.

![Ultramat 18 parameters](/assets/charging-batteries/Ultramat-18-pameters.jpeg)

7. Start the charging, based on the charger you are using.

In the Ultramat 18 charger you start charging by long pressing the START/ENTER button, after that the charger will ask for confirmation of the number of cells detected in the cell balancer. But if you are at this point it means that you followed the prerequisites and read the manual of the charger (Ultramat 18) before starting, so none of this should be new to you.

![Ultramat 18 confirmation](/assets/charging-batteries/Ultramat-18-confirmation.jpeg)

8. Check for charging state.

![Ultramat 18 charging](/assets/charging-batteries/Ultramat-18-charging.jpeg)

> [!CAUTION]
> Never leave the battery unattended during charging, always keep an eye on it in case of problems.

## Post-Charging

TBA

- LiPo Guard ()
- Storage in the right cabinet
