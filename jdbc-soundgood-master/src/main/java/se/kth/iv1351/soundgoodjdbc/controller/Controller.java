/*
 * The MIT License (MIT)
 * Copyright (c) 2020 Leif Lindbäck
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction,including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so,subject to the following conditions:
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

package se.kth.iv1351.soundgoodjdbc.controller;

import java.util.ArrayList;
import java.util.List;

import se.kth.iv1351.soundgoodjdbc.integration.soundgoodDAO;
import se.kth.iv1351.soundgoodjdbc.integration.soundgoodDBException;
import se.kth.iv1351.soundgoodjdbc.model.*;




/**
 * This is the application's only controller, all calls to the model pass here.
 * The controller is also responsible for calling the DAO. Typically, the
 * controller first calls the DAO to retrieve data (if needed), then operates on
 * the data, and finally tells the DAO to store the updated data (if any).
 */
public class Controller {
    private final soundgoodDAO soundgoodDb;

    /**
     * Creates a new instance, and retrieves a connection to the database.
     * 
     * @throws soundgoodDBException If unable to connect to the database.
     */
    public Controller() throws soundgoodDBException {
        soundgoodDb = new soundgoodDAO();
    }


    /*
    * Retrieves List of all Instruments.
    * Throws InstrumentException if unable to retrieve instruments.
    */
    public List<? extends InstrumentDTO> getAllInstruments() throws InstrumentException {
        try {
            return soundgoodDb.readAlInstruments();
        } catch (Exception e) {
            throw new InstrumentException("Unable to list instruments.", e);
        }
    }


    /* 
    * Creates a list of instruments which are currently available for renting.
    * Throws InstrumentException if unable to retrieve instruments.
    */
    public List<? extends InstrumentDTO> getAllInstrumentsAvailable() throws InstrumentException { 
        try {
            List<? extends InstrumentDTO> instruments = getAllInstruments(); 

            List<InstrumentDTO> availableinstruments = new ArrayList<>();
           for (InstrumentDTO instrument : instruments) {
                    if (instrument.getTimeRented() == null) {
                        availableinstruments.add(instrument);
                    }
            }
            return availableinstruments;    
        }
        catch (Exception e) {
            throw new InstrumentException("Unable to list instruments.", e);
        }
    }


    /* 
    * Retrieves a list of all Students. 
    * Throws StudentException if unable to retrieve Students.
    */
    public List<? extends StudentDTO> getAllStudents() throws StudentException {
        try {
            return soundgoodDb.readAllStudents();
        }
        catch (Exception e) {
            throw new StudentException("Unable to list students." , e);
        }
    }


    /* 
    * Retrieves specific Student from student_id.
    * Throws StudentException if Student does not exist.
    */
    public StudentDTO getStudent(Integer student_id) throws StudentException {
          try {
            StudentDTO student = soundgoodDb.readStudent(student_id);
            if(student.getStudentID() == null || student.getStudentName() == null) //stops ghost values
               throw new StudentException("Student does not exist");
            else
                return student;
        }
        catch (Exception e) {
            throw new StudentException("Unable to find student." , e);
        }
    }


    /*
    * Creates a List of all Instruments currently linked to specific Student (student_id)
    * Throws InstrumentException if unable to retrieve instruments.
    */
    public List<InstrumentDTO> getStudentInstruments(Integer student_id) throws InstrumentException {
        try {
            if(student_id == null)
                throw new Exception("not valid student_id");

            List<? extends InstrumentDTO> allinstruments = getAllInstruments();
            List<InstrumentDTO> yourinstruments = new ArrayList<>();
            for(InstrumentDTO instrument : allinstruments)
            {
                if(instrument.getStudentID() == student_id)
                    yourinstruments.add(instrument);
            }
            return yourinstruments;
        } 
        catch (Exception e) {
            throw new InstrumentException("Unable to list student instruments.", e);
        }
    }
   
    /*
    * Retrieves Instrument from rental_id 
    * Throws InstrumentException if unable to retrieve instruments.
    */
    public InstrumentDTO getInstrument(Integer rental_id) throws InstrumentException {
        try {
            return soundgoodDb.readInstrumentByRentalid(rental_id, false);
        } 
        catch (Exception e) {
            throw new InstrumentException("Unable to retrieve instrument.", e);
        }
    }


    /**
    * Creates Rental on Instrument with target rental_id to target student_id
    * Throws InstrumentException if unable to retrieve instruments.
    * Business Logic for Rentals are already declared as triggers in the database.
    *
    * TRIGGERS WITHIN DATABASE
    * - check_max_rented_instruments() | students <= 2 rentals 
    * - unique_rental_function() | rental_id cannot already exist in instrument_rental (already rented)
    *
    * Throws InstrumentException if unable to retrieve instruments.
    */
   public InstrumentDTO CreateRentalOnInstrument(Integer rental_id, Integer student_id) throws InstrumentException{
        try {
            InstrumentDTO selectedinstrument = soundgoodDb.readInstrumentByRentalid(rental_id, true);
            soundgoodDb.CreateRentalOnInstrument(rental_id, student_id);
            return selectedinstrument;
        } 
        catch (Exception e) {
            throw new InstrumentException("Unable to rent instrument", e);
        }
    }


    /*
    * Terminates Rental of Instrument with target rental_id and target student_id
    * Termination means first inserting Rental into Historical Rental Database 
    *             and second delete current ongoing Rental.
    * Throws InstrumentException if unable to terminate rental of instruments.
    */
    public void TerminateRentalOnInstrument(Integer rental_id, Integer student_id) throws InstrumentException {
        try {
            InstrumentDTO selectedinstrument = soundgoodDb.readInstrumentByRentalid(rental_id, true);
            soundgoodDb.DeleteRentalOnInstrument(rental_id, student_id, false);
            soundgoodDb.CreateHistoricalRentalOnInstrument(selectedinstrument, true);

            System.out.println("Rental Terminated for Instrument: " + selectedinstrument.getInstrumentName() + " " + selectedinstrument.getInstrumentBrand() 
                                + " " + selectedinstrument.getInstrumentCost() + " " + selectedinstrument.getRentalID() + " " + selectedinstrument.getTimeRented());
        } 
        catch (Exception e) {
            throw new InstrumentException("Unable to terminate rental", e);
        }
    } 
}
