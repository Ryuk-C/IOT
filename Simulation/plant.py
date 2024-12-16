class Plant:
    def __init__(self,minMoisture,maxMoisture):
        self.minMoisture = minMoisture
        self.maxMoisture = maxMoisture
        self.moisture = maxMoisture # 0 - 100 | 100 - 75 very wet | 75 - 50 wet | 50 - 0 dry
        self.waterLevel = 100 # 0 - 100
        self.__waterPumpSpeed = 1
        self.__startWatering=False

    def update(self,roomTemperature):
        if self.moisture<self.minMoisture:
            self.__startWatering=True

        if self.__startWatering and self.waterLevel>1:          
            self.moisture+=self.__waterPumpSpeed
            self.waterLevel-=self.__waterPumpSpeed
            if self.moisture>self.maxMoisture:
                self.__startWatering=False
        elif self.moisture>5:
            self.moisture-=roomTemperature/10
    
    def isWaterable(self):
        if self.moisture<self.minMoisture and self.waterLevel>1:
            return True
        return False
    
    def startWatering(self):
        self.__startWatering=True