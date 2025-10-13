package com.example.Itech_bh4.production.Entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Setter
@Getter
@Entity
@Table(name = "ZUTAT")
public class Zutat {

    @Id
    @Column(name = "ZUTATENNR")
    private Integer zutatenNr;

    @Column(name = "BEZEICHNUNG")
    private String bezeichnung;

    @Column(name = "EINHEIT")
    private String einheit;

    @Column(name = "NETTOPREIS")
    private BigDecimal nettopreis;

    @Column(name = "BESTAND")
    private Integer bestand;

    @Column(name = "LIEFERANT")
    private Integer lieferant;

    @Column(name = "KALORIEN")
    private Integer kalorien;

    @Column(name = "KOHLENHYDRATE")
    private BigDecimal kohlenhydrate;

    @Column(name = "PROTEIN")
    private BigDecimal protein;

}
