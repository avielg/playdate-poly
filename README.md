# playdate-poly

Much of the game's logic is based on the Izopod (Roly Poly) real life and behavior! (with some creative freedom...)

![image](https://user-images.githubusercontent.com/5012557/158041460-9278ff9a-1175-4b21-9148-07e0b984e79c.png)

_(from M. Shachak (1980) Energy Allocation and Life History Strategy of the Desert lsopod)_

## ToDo
- [x] Scorpion is moving faster when the tunnel is straight, slower when it's full of turns (this is the basic logic of running away vs losing the game...)
- [x] Rocks interrupting the poly that it needs to go around
- [x] Food to collect points (besides how low we got...)
- [ ] A short while after eating, Poly needs to poop: It starts shaking, crank stops working, player must press B/A fast, repeatedly, to push the poop, then poop comes out and Poly stops shaking and can keep digging (meanwhile the scorpion is getting closer!!!)

### Current State
Poly can dig, the screen scrolls up/down to follow poly.
A scorpion chases poly, following its path, if they touch - game over.
<img width="350" alt="image" src="https://user-images.githubusercontent.com/5012557/157371528-31746c8f-d822-443a-8388-68667d2bca59.png">
