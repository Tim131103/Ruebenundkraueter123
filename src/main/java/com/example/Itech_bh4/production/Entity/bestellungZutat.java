package com.example.Itech_bh4.production.Entity;

import com.example.Itech_bh4.production.Entity.IDKlasse.BestellungZutatId;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "BESTELLUNGZUTAT")
@IdClass(BestellungZutatId.class)
public class bestellungZutat {

    @Id
    @Column(name = "BESTELLUNGNR")
    private Integer bestellungNr;

    @Id
    @Column(name = "ZUTATENNR")
    private Integer zutatenNr;

    @Column(name = "MENGE")
    private Integer menge;

}
