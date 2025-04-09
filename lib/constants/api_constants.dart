
import 'package:aashni_app/constants/environment.dart';

class ApiConstants{

  static late Environment currentEnv;

  static void setEnvironment(Environment env){

    currentEnv = env;


  }

  static String  get _baseUrl{

    switch(currentEnv) {

      case Environment.dev:
        return "https://dev.aashniandco.com/rest/V1/solr";

      case Environment.stage:
        return "https://stage.aashniandco.com/rest/V1/solr";

      case Environment.prod:
        return "https://aashniandco.com/rest/V1/solr";
    }
    }



  static String get newIn => "$_baseUrl/newin";
  static String get newInAccessories => "$_baseUrl/new-in-accessories";
  static String get newInProducts => "$_baseUrl/products";
}