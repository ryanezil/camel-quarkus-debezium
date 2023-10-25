package dev.ryanezil.camel;


import java.util.Random;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mongodb.MongoDbConstants;
import org.apache.camel.dataformat.avro.AvroDataFormat;
import org.apache.camel.model.dataformat.JsonLibrary;
import org.apache.camel.model.rest.RestBindingMode;

import com.fasterxml.jackson.core.util.ByteArrayBuilder;

import dev.ryanezil.camel.model.CommonUser;

public class Route extends RouteBuilder {


    @Override
    public void configure() throws Exception {

        from("kafka:{{kafka.dbz.topic.name}}" +
                     // The consumer processor group ID
                     "?groupId={{kafka.application.groupid}}" +
                     // What to do when there is no initial offset in ZooKeeper or if an offset is out of range
                     // 'earliest' automatically reset the offset to the earliest offset
                     "&autoOffsetReset=earliest" +                  
                     // See this link: https://www.apicur.io/registry/docs/apicurio-registry/2.4.x/getting-started/assembly-configuring-kafka-client-serdes.html#registry-serdes-types-avro_registry
                     "&valueDeserializer=io.apicurio.registry.serde.avro.AvroKafkaDeserializer" +
                     "&keyDeserializer=io.apicurio.registry.serde.avro.AvroKafkaDeserializer" +
                     "&additionalProperties.apicurio.registry.url={{apicurio.registry}}" +
                     "&additionalProperties.apicurio.registry.avro-datum-provider=io.apicurio.registry.serde.avro.ReflectAvroDatumProvider"
        )
        .log("Message received from Kafka : ${body}")
        .log("    on the topic ${headers[kafka.TOPIC]}")
        .log("    on the partition ${headers[kafka.PARTITION]}")
        .log("    with the offset ${headers[kafka.OFFSET]}")
        .log("    with the key ${headers[kafka.KEY]}")
        .convertBodyTo(String.class)
        .setHeader("dbz_operation").jsonpath("$.op")
        .setHeader("dbz_source_db").jsonpath("$.source.db")
        .setHeader("dbz_source_table").jsonpath("$.source.table")
        .log("Debezium event info:")
        .log("  >> Debezium Operation = ${header.dbz_operation}")
        .log("  >> SourceDB = ${header.dbz_source_db}")
        .log("  >> SourceTABLE = ${header.dbz_source_table}")
        .choice()
            .when(header("dbz_operation").isEqualTo("c"))
                .log("DBZ op='c' - A record was created/inserted")
                .setBody().jsonpath("$.after").marshal().json(true)
                .log("The retrieved Debezium 'after' block is:\n${body}")
                .to("direct:inserted-record")
            
            .when(header("dbz_operation").isEqualTo("u"))
                .log("DBZ op='u' - A record was updated: operation not implemented")
            .when(header("dbz_operation").isEqualTo("d"))
                .log("DBZ op='d' - A record was deleted: operation not implemented")
            .otherwise()
                .log("DBZ op='r' - The record was read from table: operation not implemented")
            .end();

            

        from("direct:inserted-record")
            //Mapping JSON formats
            .toD("atlasmap:atlasmap-mappings/{{atlasmap.mapper}}")
            .unmarshal().json(JsonLibrary.Jackson, CommonUser.class )
            .log("Mapped content >>>> ${body}")
            .process(new Processor() {
                // Setting a random ID with a long value
                public void process(Exchange exchange) throws Exception {
                    CommonUser commonUser = exchange.getIn().getBody(CommonUser.class);
                    Random random = new Random();
                    commonUser.setId(random.nextLong());                    
                }
            })
            //.to("direct:show-body-classtype");
            // SEE operations here: https://camel.apache.org/components/3.21.x/mongodb-component.html#_endpoint_query_option_operation
            .to("mongodb:camelMongoClient?database={{mongodb.database}}&collection={{mongodb.users.collection}}&operation=insert")
            .log("Inserted MongoDB JSON ${body}");

    } //END configure() method

}