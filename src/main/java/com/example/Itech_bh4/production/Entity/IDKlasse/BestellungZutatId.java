package com.example.Itech_bh4.production.Entity.IDKlasse;

import java.io.Serializable;
import java.util.Objects;

public class BestellungZutatId implements Serializable {
    private Integer bestellungNr;
    private Integer zutatenNr;

    public BestellungZutatId() {}

    public BestellungZutatId(Integer bestellungNr, Integer zutatenNr) {
        this.bestellungNr = bestellungNr;
        this.zutatenNr = zutatenNr;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BestellungZutatId that = (BestellungZutatId) o;
        return Objects.equals(bestellungNr, that.bestellungNr) && Objects.equals(zutatenNr, that.zutatenNr);
    }

    @Override
    public int hashCode() {
        return Objects.hash(bestellungNr, zutatenNr);
    }
}
