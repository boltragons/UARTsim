it: compile

compile: main.o copycat.o uart_sim.o
	@g++ -g -O0 -Wall build/main.o build/copycat.o build/uart_sim.o -o bin/uart_sim

main.o: src/main.s
	@g++ -g -O0 -Wall -c src/main.s -Iinc -o build/main.o

copycat.o: src/copycat.s
	@g++ -g -O0 -Wall -c src/copycat.s -Iinc -o build/copycat.o

uart_sim.o: src/uart_sim.s
	@g++ -g -O0 -Wall -c src/uart_sim.s -Iinc -o build/uart_sim.o

clean:
	@rm build/*.o bin/uart_sim

run:
	@./bin/uart_sim

debug:
	@gdb ./bin/uart_sim
