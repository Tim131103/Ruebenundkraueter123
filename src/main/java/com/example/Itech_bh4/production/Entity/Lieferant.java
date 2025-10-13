package com.example.Itech_bh4.production.Entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import jakarta.persistence.Id;

@Getter
@Setter
@Entity
@Table(name = "LIEFERANT")
public class Lieferant {

    @Id
    @Column(name = "LIEFERANTNR")
    private Integer lieferantNr;

    @Column(name = "LIEFERANTENNAME")
    private String lieferantenName;

    @Column(name = "STRASSE")
    private String strasse;

    @Column(name = "Hausnr")
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
