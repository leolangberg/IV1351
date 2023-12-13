/*
 * The MIT License
 *
 * Copyright 2017 Leif Lindbäck <leifl@kth.se>.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package se.kth.iv1351.soundgoodjdbc.view;

import java.util.List;
import java.util.Scanner;

import se.kth.iv1351.soundgoodjdbc.controller.Controller;
import se.kth.iv1351.soundgoodjdbc.model.*;


/**
 * Reads and interprets user commands. This command interpreter is blocking, the user
 * interface does not react to user input while a command is being executed.
 */
public class BlockingInterpreter {
    private static final String PROMPT = "> ";
    private final Scanner console = new Scanner(System.in);
    private Controller ctrl;
    private boolean keepReceivingCmds = false;

    /**
     * Creates a new instance that will use the specified controller for all operations.
     * 
     * @param ctrl The controller used by this instance.
     */
    public BlockingInterpreter(Controller ctrl) {
        this.ctrl = ctrl;
    }

    /**
     * Stops the commend interpreter.
     */
    public void stop() {
        keepReceivingCmds = false;
    }

    /**
     * Interprets and performs user commands. This method will not return until the
     * UI has been stopped. The UI is stopped either when the user gives the
     * "quit" command, or when the method <code>stop()</code> is called.
     */
    public void handleCmds() {
        keepReceivingCmds = true;
        Integer student_id = null; //login
        while (keepReceivingCmds) {
            try {
                CmdLine cmdLine = new CmdLine(readNextLine());
                switch (cmdLine.getCmd()) {
                    case HELP:
                        for (Command command : Command.values()) {
                            if (command == Command.ILLEGAL_COMMAND) {
                                continue;
                            }
                            System.out.println(command.toString().toLowerCase());
                        }
                        break;

                    case QUIT:
                        keepReceivingCmds = false;
                        break;

                    case LOGIN:
                        student_id = Integer.parseInt(cmdLine.getParameter(0));
                        StudentDTO stud = ctrl.getStudent(student_id);
                        System.out.println("logged in as student_id: " + student_id);
                        break;
                    
                    case LOGOUT:
                        student_id = null;
                        System.out.println("logged out");
                        break;

                    case IN_STOCK:
                        List<? extends InstrumentDTO> instruments = ctrl.getAllInstrumentsAvailable();
                        System.out.printf("%-15s%-10s%-15s%-10s%-10s\n", "instrument_id", "Name", "Brand", "Cost", "rental_id");
                        System.out.println();
                        for (InstrumentDTO instrument : instruments) {
                            System.out.printf("%-15s%-10s%-15s%-10s%-10s\n",
                            instrument.getInstrumentID(),
                            instrument.getInstrumentName(),
                            instrument.getInstrumentBrand(),
                            instrument.getInstrumentCost(),
                            instrument.getRentalID());
                        }
                        break;
                    
                    case STUDENT_RENTALS: 
                        List<InstrumentDTO> studentinstruments = ctrl.getStudentInstruments(student_id);
                        System.out.printf("%-15s%-10s%-15s%-10s%-10s\n", "instrument_id", "Name", "Brand", "Cost", "rental_id");
                        System.out.println();
                        for (InstrumentDTO instrument : studentinstruments) {
                            System.out.printf("%-15s%-10s%-15s%-10s%-10s\n",
                            instrument.getInstrumentID(),
                            instrument.getInstrumentName(),
                            instrument.getInstrumentBrand(),
                            instrument.getInstrumentCost(),
                            instrument.getRentalID());
                        }
                        break;

                    case RENT:
                        Integer rental_id = Integer.parseInt(cmdLine.getParameter(0));
                        InstrumentDTO yourinstrument = ctrl.CreateRentalOnInstrument(rental_id, student_id);
                        System.out.println("instrument has now been rented: ");
                        System.out.println(yourinstrument.getInstrumentID() + " " + yourinstrument.getInstrumentName() + " " + yourinstrument.getInstrumentBrand() + " " + yourinstrument.getInstrumentCost() + " " + yourinstrument.getRentalID());
                        break;

                    case TERMINATE_RENTAL:
                        Integer terminate_rental_id = Integer.parseInt(cmdLine.getParameter(0));
                        ctrl.TerminateRentalOnInstrument(terminate_rental_id, student_id);
                        break;

                    default:
                        System.out.println("illegal command");
                }
            } catch (Exception e) {
                System.out.println("Operation failed");
                System.out.println(e.getMessage());
                e.printStackTrace();   
            }
        }
    }

    private String readNextLine() {
        System.out.print(PROMPT);
        return console.nextLine();
    }
}
