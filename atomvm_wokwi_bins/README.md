# VS code extensions

https://marketplace.visualstudio.com/items?itemName=Wokwi.wokwi-vscode

(optional - for reflash on save) https://marketplace.visualstudio.com/items?itemName=appulate.filewatcher

(optional for manual task runner) https://marketplace.visualstudio.com/items?itemName=SanaAjani.taskrunnercode or https://marketplace.visualstudio.com/items?itemName=seunlanlege.action-buttons

Or just good old manual "rebar3 as sim packbeam && touch ./atomvm_wokwi_bins/flasher_args.json" in your terminal


# Quick Notes

Obviously your AtomVM builds needs to match the board used. You can even simulate a board like P4.

You can find, create and edit diagram.json boards on wokwi.com eg. you can fork/edit this repo board here https://wokwi.com/projects/389514739303460865 - click the "diagram.json" tab and copy/paste it into this project's diagram.json - google for boards, examples etc. - vs code will prevent you from editing diagram.json - so use another editor for that one:/

https://github.com/atomvm/atomvm_dht is included in the AtomVM build - but seems to only return 0.0 - it's seems to be finicky about library used https://docs.wokwi.com/parts/wokwi-dht22#controlling-the-temperature - probably not worthwhile fixing.

https://github.com/atomvm/atomvm_ssd1306 and https://github.com/atomvm/atomvm_neopixel is also included in the build.