package com.example.Itech_bh4.production.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "KUNDE")
public class Kunde {

    // Getters and setters
    @Id
    @Column(name = "KUNDENNR")
    private Integer kundennr;

    @Column(name = "NACHNAME")
    private String nachname;

    @Column(name = "VORNAME")
    private String vorname;

    @Column(name = "GEBURTSDATUM")
    private LocalDate geburtsdatum;

    @Column(name = "STRASSE")
    private String strasse;

    @Column(name = "HAUSNR")
    private String hausnr;

    @Column(name = "PLZ")
    private String plz;

    @Column(name = "ORT")
    private String ort;

    @Column(name = "TELEFON")
    private String telefon;

    @Column(name = "EMAIL")
    private String email;

}
