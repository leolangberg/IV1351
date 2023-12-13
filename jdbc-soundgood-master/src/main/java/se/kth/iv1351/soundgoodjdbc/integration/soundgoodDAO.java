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

package se.kth.iv1351.soundgoodjdbc.integration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import se.kth.iv1351.soundgoodjdbc.model.*;


/**
 * This data access object (DAO) encapsulates all database calls in the bank
 * application. No code outside this class shall have any knowledge about the
 * database.
 */
public class soundgoodDAO {
    //instrument table
    private static final String INSTRUMENT_TABLE_NAME = "instrument";   
    private static final String INSTRUMENT_PK_COLUMN_NAME = "instrument_id";
    private static final String INSTRUMENT_COLUMN_NAME = "instrument_type_name";

    //in_stock table
    private static final String IN_STOCK_TABLE_NAME = "in_stock";
    private static final String IN_STOCK_PK_COLUMN_NAME = "rental_id";
    private static final String IN_STOCK_INSTRUMENT_ID = "instrument_id";
    private static final String IN_STOCK_BRAND_COLUMN_NAME = "brand";
    private static final String IN_STOCK_COST_COLUMN_NAME = "cost";

    //instrument_rental table
    private static final String INSTRUMENT_RENTAL_TABLE_NAME = "instrument_rental";
    private static final String INSTRUMENT_RENTAL_RENTAL_ID = "rental_id";
    private static final String INSTRUMENT_RENTAL_STUDENT_ID = "student_id";
    private static final String INSTRUMENT_TIME_RENTED = "time_rented";

    //historical_rental table
    private static final String HISTORICAL_RENTAL_TABLE_NAME = "historical_rental";
    private static final String HISTORICAL_RENTAL_RENTAL_ID = "rental_id";
    private static final String HISTORICAL_RENTAL_COST = "monthly_cost";
    private static final String HISTORICAL_RENTAL_STUDENT_ID = "student_id";
    private static final String HISTORICAL_TIME_RENTED = "time_rented";
    private static final String HISTORICAL_TIME_RETURNED = "time_returned";

    //student table
    private static final String STUDENT_TABLE_NAME = "student";
    private static final String STUDENT_STUDENT_ID = "student_id";

    //person table
    private static final String PERSON_TABLE_NAME = "person";
    private static final String PERSON_ID = "person_id";
    private static final String PERSON_NAME = "name";


    private Connection connection;
    private PreparedStatement readAllinstrumentStmt;
    private PreparedStatement readAllstudentsStmt;
    private PreparedStatement readStudentStmt;
    private PreparedStatement readStudentInstrumentStmt;
    private PreparedStatement CreateInstrumentRentalStmt;
    private PreparedStatement readInstrumentLockingForUpdateStmt;
    private PreparedStatement readInstrumentStmt;
    private PreparedStatement deleteRentalOnInstrumentStmt;
    private PreparedStatement CreateHistoricalRentalOnInstrumentStmt;

    /**
     * Constructs a new DAO object connected to the bank database.
     */
    public soundgoodDAO() throws soundgoodDBException {
        try {
            connectTosoundgoodDB();
            prepareStatements();
        } catch (ClassNotFoundException | SQLException exception) {
            throw new soundgoodDBException("Could not connect to datasource.", exception);
        }
    }

    /* 
    * List of all Instruments currently in in_stock 
    * Object is also joined on 'instrument_rental' to encapsulate
    * any Student currently linked to an Instrument.
    * Throws soundgoodDBException if failed to search for Instruments.
    */
    public List<Instrument> readAlInstruments() throws soundgoodDBException {
        
        String failureMsg = "Could not list instruments.";
        List<Instrument> instruments = new ArrayList<>();
        try (ResultSet result = readAllinstrumentStmt.executeQuery()){
            while (result.next()) {

                int instrument_id = result.getInt(INSTRUMENT_PK_COLUMN_NAME);
                String instrument_name = result.getString(INSTRUMENT_COLUMN_NAME);
                String instrument_brand = result.getString(IN_STOCK_BRAND_COLUMN_NAME);
                double instrument_cost = result.getDouble(IN_STOCK_COST_COLUMN_NAME);
                int rental_id = result.getInt(IN_STOCK_PK_COLUMN_NAME);
                String time_rented = result.getString(INSTRUMENT_TIME_RENTED);

                //handle integer null cases
                String cur = result.getString(INSTRUMENT_RENTAL_STUDENT_ID);
                Integer student_id = null;
                if(cur != null) {
                    student_id = Integer.parseInt(cur);
                    instruments.add(new Instrument(instrument_id, instrument_name, instrument_brand, instrument_cost, rental_id, time_rented, student_id));
                }
                else {
                    instruments.add(new Instrument(instrument_id, instrument_name, instrument_brand, instrument_cost, rental_id, time_rented, (Integer) null));
                }
            }
            connection.commit();
        } 
        catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        }
        return instruments;
    }



    /*  
    * Retrieves a List of all Students in 'student' table together with 
    * the name of the student from the 'person' table.
    * Throws soundgoodDBException if failed to search Students. 
    */
    public List<Student> readAllStudents() throws soundgoodDBException {
        String failureMsg = "Could not list students.";
        List<Student> students = new ArrayList<>();
        try (ResultSet result = readAllstudentsStmt.executeQuery()) {
            while (result.next()) {
                students.add(new Student(result.getInt(STUDENT_STUDENT_ID), result.getString(PERSON_NAME)));
            }
            connection.commit();
        }
          catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        }
        return students;
    }


    /* 
    * Retrieves specific Student based on student_id.
    * Throws soundgoodDBException if failed to search for the Student.
    */
    public Student readStudent(Integer student_id) throws soundgoodDBException {
        String failureMsg = " Could not find student: " + student_id;
        ResultSet result = null;
        try {
            readStudentStmt.setInt(1, student_id);
            result = readStudentStmt.executeQuery();
            if(result.next()) {
                System.out.println("student: " + result.getInt(STUDENT_STUDENT_ID) + " " + result.getString(PERSON_NAME));
                return new Student(result.getInt(STUDENT_STUDENT_ID), result.getString(PERSON_NAME));
            }
            connection.commit();
        }
        catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        } 
        finally {
            closeResultSet(failureMsg, result);
        }
        return null;
    }

   


    
    /* Retrieves Instrument with corresponding rental_id.
    *  Boolean lockExclusive if true, will lock the specific Instrument 
    *  from being changed from other connections until a commit() has been perform (SELECT FOR UPDATE) (FOR NO KEY UPDATE).
    *  Throws soundgoodDBException if failed to search for Instrument. 
    */
    public Instrument readInstrumentByRentalid(Integer rental_id, boolean lockExclusive) throws soundgoodDBException {
        String failureMsg = "Could not find instruments";
        ResultSet result = null;
        try{
            if(lockExclusive == true) {  //if lock then SELECT FOR UPDATE on specified object
                ResultSet resultlockExclusive;
                readInstrumentLockingForUpdateStmt.setInt(1, rental_id);
                resultlockExclusive = readInstrumentLockingForUpdateStmt.executeQuery(); 
            }
            readInstrumentStmt.setInt(1, rental_id); //Object is retrieved
            result = readInstrumentStmt.executeQuery();
            if(result.next()) {
                int instrument_id = result.getInt(INSTRUMENT_PK_COLUMN_NAME);
                String instrument_name = result.getString(INSTRUMENT_COLUMN_NAME);
                String instrument_brand = result.getString(IN_STOCK_BRAND_COLUMN_NAME);
                double instrument_cost = result.getDouble(IN_STOCK_COST_COLUMN_NAME);
                 
                String time_rented = result.getString(INSTRUMENT_TIME_RENTED);
                String cur = result.getString(INSTRUMENT_RENTAL_STUDENT_ID);
                Integer student_id = null;  
                if(cur != null) {    //handle integer null cases (converter)
                    student_id = Integer.parseInt(cur);
                    return new Instrument(instrument_id, instrument_name, instrument_brand, instrument_cost, rental_id, time_rented, student_id);
                }
                else {
                    return new Instrument(instrument_id, instrument_name, instrument_brand, instrument_cost, rental_id, time_rented, (Integer) null);
                }
            }
            if(lockExclusive == false)
                connection.commit();
        }
        catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        } 
        finally {
            closeResultSet(failureMsg, result);
        }
        return null;
    }




    /* 
    * Creates new instance of rental on instrument with target rental_id to target student_id.
    * (Function is only used on already locked Instruments) 
    * Throws soundgoodDBException if failed to create rental. 
    */
    public void CreateRentalOnInstrument(Integer rental_id, Integer student_id) throws soundgoodDBException {
        String failureMsg = "Could not create rental for rental_id: " + rental_id;
        try {
            CreateInstrumentRentalStmt.setInt(1, rental_id);
            CreateInstrumentRentalStmt.setInt(2, student_id);
            CreateInstrumentRentalStmt.executeUpdate();
            connection.commit();
        }
        catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        }
    }
    
    /* 
    * Inserts Rental of Instrument into historical rental database.
    * Boolean finishedTransaction if false will not commit, meaning that transaction process is not complete.
    * Throws soundgoodDBException if failed to create historical rental instance. 
    */
    public void CreateHistoricalRentalOnInstrument(InstrumentDTO selectedinstrument, boolean finishedTransaction) throws soundgoodDBException {
        String failureMsg = "could not create historical rental on rental_id: " + selectedinstrument.getRentalID();
        try {
            CreateHistoricalRentalOnInstrumentStmt.setInt(1, selectedinstrument.getRentalID());
            CreateHistoricalRentalOnInstrumentStmt.setDouble(2, selectedinstrument.getInstrumentCost());
            CreateHistoricalRentalOnInstrumentStmt.setInt(3, selectedinstrument.getStudentID());

            String time_rented = selectedinstrument.getTimeRented(); //convert String into Date for SQL
            SimpleDateFormat s = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date date = s.parse(time_rented);
            java.sql.Date sqlDate = new java.sql.Date(date.getTime()); 

            CreateHistoricalRentalOnInstrumentStmt.setDate(4, sqlDate);
            CreateHistoricalRentalOnInstrumentStmt.executeUpdate();
            if (finishedTransaction == true) {
                connection.commit();
            }
        }
        catch (ParseException | SQLException sqle) {
            handleException(failureMsg, sqle);
        }
    }
    /*
    * Deletes Rental of Instrument in 'instrument_rental' table (which keeps track of current rentals)
    * Boolean finishedTransaction if false will not commit, meaning that transaction process is not complete.
    * Throws soundgoodDBException if failed to create delete current rental instance.
    */
    public void DeleteRentalOnInstrument(Integer rental_id, Integer student_id, boolean finishedTransaction) throws soundgoodDBException {
        String failureMsg = "could not delete instrument rental for rental_id: " + rental_id;
        try {
            deleteRentalOnInstrumentStmt.setInt(1, rental_id);
            deleteRentalOnInstrumentStmt.setInt(2, student_id);
            int updatedRows = deleteRentalOnInstrumentStmt.executeUpdate();
            if (updatedRows != 1) {
                handleException(failureMsg, null);
            }
            if (finishedTransaction == true) { 
                connection.commit();           
            }                             
        }
        catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        } 
    }


    /**
     * Commits the current transaction.
     * 
     * @throws soundgoodDBException If unable to commit the current transaction.
     */
    public void commit() throws soundgoodDBException {
        try {
            connection.commit();
        } catch (SQLException e) {
            handleException("Failed to commit", e);
        }
    }

    private void connectTosoundgoodDB() throws ClassNotFoundException, SQLException {
        connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres",
                "postgres", "postgres");
        // connection =
        // DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb",
        // "mysql", "mysql");
        connection.setAutoCommit(false);
    }

    private void prepareStatements() throws SQLException {  
                           
        readAllinstrumentStmt = connection.prepareStatement("SELECT " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_PK_COLUMN_NAME + ", " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_COLUMN_NAME + ", " + INSTRUMENT_RENTAL_TABLE_NAME + "." + INSTRUMENT_RENTAL_STUDENT_ID +
                                ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_BRAND_COLUMN_NAME + ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_COST_COLUMN_NAME + ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_PK_COLUMN_NAME + ", " + INSTRUMENT_RENTAL_TABLE_NAME + "." + INSTRUMENT_TIME_RENTED  + 
                                " FROM " + INSTRUMENT_TABLE_NAME + " LEFT JOIN " + IN_STOCK_TABLE_NAME  + " ON " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_PK_COLUMN_NAME + " = " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_INSTRUMENT_ID +
                                " LEFT JOIN " + INSTRUMENT_RENTAL_TABLE_NAME + " ON " + INSTRUMENT_RENTAL_TABLE_NAME + "." + INSTRUMENT_RENTAL_RENTAL_ID + " = " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_PK_COLUMN_NAME);

        readAllstudentsStmt = connection.prepareStatement("SELECT " + STUDENT_STUDENT_ID + ", " + PERSON_NAME + " FROM " + STUDENT_TABLE_NAME + " LEFT JOIN " + PERSON_TABLE_NAME+ " ON " + PERSON_TABLE_NAME + "." + PERSON_ID + " = " + STUDENT_TABLE_NAME + "." + STUDENT_STUDENT_ID);

        readStudentStmt = connection.prepareStatement("SELECT " + STUDENT_STUDENT_ID + ", " + PERSON_NAME + " FROM " + STUDENT_TABLE_NAME + " LEFT JOIN " + PERSON_TABLE_NAME + " ON " + PERSON_TABLE_NAME + "." + PERSON_ID + " = " + STUDENT_TABLE_NAME + "." + STUDENT_STUDENT_ID + " WHERE " + STUDENT_TABLE_NAME + "." + STUDENT_STUDENT_ID + " = ?");

        CreateInstrumentRentalStmt = connection.prepareStatement("INSERT INTO " + INSTRUMENT_RENTAL_TABLE_NAME + "( " + INSTRUMENT_RENTAL_RENTAL_ID + ", " + INSTRUMENT_RENTAL_STUDENT_ID + " ) VALUES ( ?, ? )");

        CreateHistoricalRentalOnInstrumentStmt = connection.prepareStatement("INSERT INTO " + HISTORICAL_RENTAL_TABLE_NAME + "( " + HISTORICAL_RENTAL_RENTAL_ID + ", " + HISTORICAL_RENTAL_COST + ", " + HISTORICAL_RENTAL_STUDENT_ID + ", " + HISTORICAL_TIME_RENTED + " ) VALUES( ?, ?, ?, ? )");

        deleteRentalOnInstrumentStmt = connection.prepareStatement("DELETE FROM " + INSTRUMENT_RENTAL_TABLE_NAME + " WHERE " + INSTRUMENT_RENTAL_RENTAL_ID + " = ? AND " + INSTRUMENT_RENTAL_STUDENT_ID + " = ?");

        readInstrumentLockingForUpdateStmt = connection.prepareStatement("SELECT " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_PK_COLUMN_NAME + ", " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_COLUMN_NAME + ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_BRAND_COLUMN_NAME + ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_COST_COLUMN_NAME + 
                                                                         " FROM " + IN_STOCK_TABLE_NAME + " JOIN " + INSTRUMENT_TABLE_NAME + " ON " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_PK_COLUMN_NAME + " = " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_INSTRUMENT_ID +
                                                                         " WHERE " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_PK_COLUMN_NAME + " = ? FOR NO KEY UPDATE");

        readInstrumentStmt = connection.prepareStatement("SELECT " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_PK_COLUMN_NAME + ", " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_COLUMN_NAME + ", " + INSTRUMENT_RENTAL_TABLE_NAME + "." + INSTRUMENT_RENTAL_STUDENT_ID +
                                ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_BRAND_COLUMN_NAME + ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_COST_COLUMN_NAME + ", " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_PK_COLUMN_NAME + ", " + INSTRUMENT_RENTAL_TABLE_NAME + "." + INSTRUMENT_TIME_RENTED  + 
                                " FROM " + INSTRUMENT_TABLE_NAME + " LEFT JOIN " + IN_STOCK_TABLE_NAME  + " ON " + INSTRUMENT_TABLE_NAME + "." + INSTRUMENT_PK_COLUMN_NAME + " = " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_INSTRUMENT_ID +
                                " LEFT JOIN " + INSTRUMENT_RENTAL_TABLE_NAME + " ON " + INSTRUMENT_RENTAL_TABLE_NAME + "." + INSTRUMENT_RENTAL_RENTAL_ID + " = " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_PK_COLUMN_NAME +
                                " WHERE " + IN_STOCK_TABLE_NAME + "." + IN_STOCK_PK_COLUMN_NAME + " = ?");

   }

    private void handleException(String failureMsg, Exception cause) throws soundgoodDBException {
        String completeFailureMsg = failureMsg;
        try {
            connection.rollback();
        } catch (SQLException rollbackExc) {
            completeFailureMsg = completeFailureMsg +
                    ". Also failed to rollback transaction because of: " + rollbackExc.getMessage();
        }
        if (cause != null) {
            throw new soundgoodDBException(failureMsg, cause);
        } else {
            throw new soundgoodDBException(failureMsg);
        }
    }

    private void closeResultSet(String failureMsg, ResultSet result) throws soundgoodDBException {
        try {
            result.close();
        } catch (Exception e) {
            throw new soundgoodDBException(failureMsg + " Could not close result set.", e);
        }
    }
}
